# This collection stores a history of game states for each non-lobby room.
# It is implemented as a tree of states, each of which points to its parent.
#   room_id: room _id
#   previous_state_id: game_state _id
#   state: arbitrary JSON-able state
#   views: dict mapping user_id -> view of state

class @GameStates extends @Collection
  @collection = new Meteor.Collection 'game_states'
  @fields = [
    'room_id',
    'previous_state_id',
    'state',
    'views',
  ]

  @publish: (user_id, room_ids) ->
    check(user_id, String)
    check(room_ids, [String])
    # Restrict the user's view of states to rooms that he is in.
    rooms = Rooms.find(_id: {$in: room_ids}, user_ids: user_id).fetch()
    legal_room_ids = (room._id for room in rooms)
    @find(room_id: $in: room_ids)

  @create_game: (user_id, name, rules, initial_state, initial_views) ->
    console.log user_id, name, rules, initial_state, initial_views
    room_id = Rooms.create_room(name, rules, [user_id])
    room = Rooms.findOne(_id: room_id)
    @update_game_state(room, initial_state, initial_views)

  @update_game_state: (room, state, views) ->
    check(room._id, String)
    check(room.game_state_id, Match.OneOf(String, null))
    check((user_id for user_id of views), [String])
    new_state_id = @insert(
      room_id: room._id,
      previous_state_id: room.game_state_id,
      state: state,
      views: views,
    )
    Rooms.update({_id: room.id, game_state_id: room.game_state_id},
      $set: game_state_id: new_state_id,
    )
