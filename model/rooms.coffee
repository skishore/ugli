# This collection stores data about rooms, which can be lobbies,
# singleplayer games, or multiplayer games.
#   name: string
#   user_ids: [user _ids]
#   is_game: bool
# privates and invites fields to come soon.

class @Rooms extends Collection
  @collection = new Meteor.Collection 'rooms'
  @fields = [
    'name',
    'user_ids',
    'is_game',
  ]
  if Meteor.isServer
    @collection._ensureIndex 'name', unique: true

  @publish: (user_id) ->
    check user_id, String
    @find()

  @create_room: (name, is_game) ->
    # Create a new game room with no initial game state. Return its _id.
    check name, String
    check is_game, Boolean
    @insert
      name: name,
      user_ids: [],
      is_game: is_game,

  @get_lobby = ->
    lobby = @findOne(name: Common.lobby_name)
    if not lobby? and Meteor.isServer
      @create_room Common.lobby_name, false
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
