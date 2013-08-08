# This collection stores data about rooms, which can be lobbies,
# singleplayer games, or multiplayer games.
#   name: string
#   user_ids: [user _ids]
#   rules: dict or null (for lobbies)
#   game_state_id: game_state _id or null (for lobbies)
# privates and invites fields to come soon.

class @Rooms extends @Collection
  @collection = new Meteor.Collection 'rooms'
  @fields = [
    'name',
    'user_ids',
    'rules',
    'game_state_id',
  ]
  if Meteor.isServer
    @collection._ensureIndex 'name', unique: true

  @publish: (user_id) ->
    check user_id, String
    @find()

  @create_room: (name, user_ids, rules) ->
    # Create a new game room with no initial game state. Return its _id.
    check name, String
    check user_ids, [String]
    check rules, Match.OneOf(Object, null)
    @insert
      name: name,
      user_ids: user_ids,
      rules: rules,
      game_state_id: null,

  @get_lobby = ->
    lobby = @findOne(name: Common.lobby_name)
    if not lobby? and Meteor.isServer
      @create_room Common.lobby_name, [], null
      lobby = @findOne(name: Common.lobby_name)
    lobby

  @join_room = (user_id, room_id) ->
    # TODO(skishore): This call should notify the UGLI server for this room.
    check user_id, String
    check room_id, String
    @update({_id: room_id}, $addToSet: 'user_ids': user_id)

  @leave_room = (user_id, room_id) ->
    # TODO(skishore): This call should notify the UGLI server for this room.
    # We may also want to destroy empty game rooms.
    check user_id, String
    check room_id, String
    @update({_id: room_id}, $pull: 'user_ids': user_id)

  @boot_users = (user_ids) ->
    # TODO(skishore): This call should notify the UGLI server for this room.
    # We may also want to destroy empty game rooms.
    check user_ids, [String]
    @update({}, $pull: 'user_ids': $in: user_ids)
