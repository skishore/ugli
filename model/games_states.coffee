# This collection stores a history of game states for each non-lobby room.
# The state with the latest index is the current state for the room.
#   room_id: room _id
#   index: int
#   state: arbitrary JSON-able state
#   views: dict mapping user_id -> view of state

class @GameStates extends Collection
  @collection = new Meteor.Collection 'game_states'
  @fields = [
    'room_id',
    'index',
    'state',
    'views',
  ]
  if Meteor.isServer
    @collection._ensureIndex {room_id: 1, index: -1}, unique: true

  @publish: (user_id, room_ids) ->
    check user_id, String
    check room_ids, [String]
    # Restrict the user's view of states to rooms that he is in.
    rooms = Rooms.find(_id: {$in: room_ids}, user_ids: user_id).fetch()
    legal_room_ids = (room._id for room in rooms)
    fields = index: 1, room_id: 1
    fields["views.#{user_id}"] = 1
    @find({room_id: $in: room_ids}, fields: fields)

  @get_current_state: (room_id) ->
    @findOne({room_id: room_id}, sort: index: -1)

  @update_game_state: (room_id, cur_index, new_state, new_views) ->
    # Update the state of a room that is currently at state cur_index.
    # Return the new state _id on success and false on failure.
    check room_id, String
    check cur_index, Number
    check new_state, Object
    check (user_id for user_id of new_views), [String]
    try
      return @insert
        room_id: room_id,
        index: cur_index + 1,
        state: new_state,
        views: new_views,
    false
