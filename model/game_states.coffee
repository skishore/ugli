# This collection stores a history of game states for each non-lobby room.
# The state with the latest index is the current state for the room.
#   room_id: room _id
#   index: int
#   players: [String] snapshot of usernames at time of computation
#   state: arbitrary JSON-able state
#   user_views: dict mapping user_id -> user's view of state
#   public_view: public view of game state
#   active: bool

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

  @save_context: (room_id, cur_index, context) ->
    # Update the state of a room that is currently at state cur_index.
    # Return the new state _id on success and false on failure.
    check room_id, String
    check cur_index, Number
    check context, UGLIServerContext
    [user_views, public_view] = context._get_views()
    try
      return @insert
        room_id: room_id
        index: cur_index + 1
        players: context.players
        state: context.state
        user_views: user_views
        public_view: public_view
        active: true
    false
