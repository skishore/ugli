# This collection stores a history of game states for each non-lobby room.
# The state with the latest index is the current state for the room.
#   room_id: room _id
#   index: int
#   players: [String] snapshot of usernames at time of computation
#   state: arbitrary JSON-able state
#   user_views: dict mapping user_id -> user's view of state
#   public_view: public view of game state
#   active: bool
#   created: ts

class @GameStates extends Collection
  @collection = new Meteor.Collection 'game_states'
  @fields = [
    'room_id',
    'index',
    'players',
    'state',
    'user_views',
    'public_view',
    'active',
    'created',
  ]
  if Meteor.isServer
    @collection._ensureIndex {room_id: 1, index: -1}, unique: true
    @collection._ensureIndex 'active'

  @publish: (user_id, room_ids) ->
    check user_id, String
    # Drop the room_ids param and restrict the user's view to rooms he is in.
    rooms = Rooms.get_user_rooms user_id
    legal_room_ids = (room._id for room in rooms)
    fields =
      room_id: 1
      index: 1
      players: 1
    fields["user_views.#{user_id}"] = 1
    @find({active: true, room_id: $in: legal_room_ids}, fields: fields)

  @publish_public_views: ->
    @find(
      {active: true},
      fields:
        room_id: 1
        index: 1
        players: 1
        public_view: 1
    )

  @get_current_state: (room_id) ->
    @findOne({room_id: room_id}, sort: index: -1)

  @get_current_states: ->
    game_states = @find(active: true).fetch()
    current_states = {}
    for game_state in game_states
      if (current_states[game_state.room_id]?.index or 0) < game_state.index
        current_states[game_state.room_id] = game_state
    current_states

  @save_state: (room_id, game) ->
    check room_id, String
    [user_views, public_view] = game._get_views()
    try
      result = @insert
        room_id: room_id
        index: game._index
        players: game.players
        state: game.state
        user_views: user_views
        public_view: public_view
      @cleanup room_id: room_id, index: $lt: game._index
      return result
    false

  @cleanup_old_states: ->
    game_states = @find(active: true).fetch()
    current_states = @get_current_states()
    old_state_ids = (
      game_state._id for game_state in game_states \
      when game_state.index < current_states[game_state.room_id].index
    )
    @cleanup _id: $in: old_state_ids

  @cleanup_orphaned_states: ->
    # There are two conditions by which a game state can be orphaned:
    #   - Its room is not active.
    #   - It is not in the UGLICore in-memory list of games.
    rooms = Rooms.find({active: true}, fields: _id: 1).fetch()
    room_ids = (room._id for room in rooms when room._id of UGLICore.games)
    @cleanup room_id: $not: $in: room_ids
