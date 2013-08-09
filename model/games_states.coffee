# This collection stores a history of game states for each non-lobby room.
# The state with the latest index is the current state for the room.
#   room_id: room _id
#   index: int
#   players: [String] snapshot of usernames at time of computation
#   state: arbitrary JSON-able state
#   views: dict mapping user_id -> user's view of state

class @GameStates extends Collection
  @collection = new Meteor.Collection 'game_states'
  @fields = [
    'room_id',
    'index',
    'players',
    'state',
    'views',
  ]
  if Meteor.isServer
    @collection._ensureIndex {room_id: 1, index: -1}, unique: true

  @publish: (user_id, room_ids) ->
    check user_id, String
    # Drop the room_ids param and restrict the user's view to rooms he is in.
    rooms = Rooms.get_user_rooms user_id
    legal_room_ids = (room._id for room in rooms)
    fields =
      room_id: 1
      index: 1
      players: 1
    fields["views.#{user_id}"] = 1
    @find({room_id: $in: legal_room_ids}, fields: fields)

  @get_current_state: (room_id) ->
    @findOne({room_id: room_id}, sort: index: -1)

  @save_game_state: (room_id, cur_index, players, state, views) ->
    # Update the state of a room that is currently at state cur_index.
    # Return the new state _id on success and false on failure.
    check room_id, String
    check cur_index, Number
    check players, [String]
    check state, Object
    check (user_id for user_id of views), [String]
    try
      return @insert
        room_id: room_id,
        index: cur_index + 1,
        players: players,
        state: state,
        views: views,
    false
