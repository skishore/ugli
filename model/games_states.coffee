# This collection stores a history of game states for each non-lobby room.
# It is implemented as a tree of states, each of which points to its parent.
#   room_id: room _id
#   previous_state_id: game_state _id
#   state: arbitrary JSON-able state
#   views: dict mapping user_id -> view of state

class @GameStates extends Collection
  @collection = new Meteor.Collection 'game_states'
  @fields = [
    'room_id',
    'previous_state_id',
    'state',
    'views',
  ]
  if Meteor.isServer
    @collection._ensureIndex 'room_id'

  @publish: (user_id, room_ids) ->
    check user_id, String
    check room_ids, [String]
    # Restrict the user's view of states to rooms that he is in.
    rooms = Rooms.find(_id: {$in: room_ids}, user_ids: user_id).fetch()
    legal_room_ids = (room._id for room in rooms)
    fields = {}
    fields["views.#{user_id}"] = 1
    @find({room_id: $in: room_ids}, fields: fields)

  @update_game_state: (room_id, state, views) ->
    # Update a game to the new state. Return true on success.
    room = Rooms.findOne(_id: room_id)
    check room._id, String
    check room.game_state_id, Match.OneOf(String, null)
    check (user_id for user_id of views), [String]
    new_state_id = @insert
      room_id: room._id,
      previous_state_id: room.game_state_id,
      state: state,
      views: views,
    Rooms.update(
      {_id: room._id, game_state_id: room.game_state_id},
      $set: game_state_id: new_state_id,
    )
    @check_update_result room._id, room.game_state_id, new_state_id

  @check_update_result: (room_id, previous_state_id, new_state_id) ->
    # Return true if an update from the previous state to the new one succeeded.
    room = Rooms.findOne(_id: room_id)
    if not room?
      return false
    cur_state_id = room.game_state_id
    if cur_state_id == new_state_id
      return true
    # We've moved past the new state. Walk the tree to see if we encounter it.
    game_states = GameStates.find(
      {room_id: room_id},
      fields: {_id: 1, previous_state_id: 1}
    ).fetch()
    parent_map = {}
    for game_state in game_states
      parent_map[game_state._id] = game_state.previous_state_id
    while cur_state_id? and cur_state_id != previous_state_id
      cur_state_id = parent_map[cur_state_id]
      if cur_state_id == new_state_id
        return true
    false
