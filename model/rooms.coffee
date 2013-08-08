# This collections stores data about rooms, which can be lobbys,
# singleplayer games, or multiplayer games.
#   name: string
#   user_ids: [user _ids]
#   rules: dict or null (for lobbies)
# privates and invites fields to come soon.

class @Rooms extends @Collection
  @collection = new Meteor.Collection 'rooms'
  @fields = [
    'name',
    'user_ids',
    'rules',
  ]
  if Meteor.isServer
    @collection._ensureIndex 'name', unique: true

  @publish: (user_id) ->
    check(user_id, String)
    @find()

  @get_lobby = ->
    result = @findOne(name: Common.lobby_name)
    if not result and Meteor.isServer
      @insert(
        name: Common.lobby_name,
        user_ids: [],
        rules: null,
      )
      result = @findOne(name: Common.lobby_name)
    result

  @join_room = (user_id, room_id) ->
    check(user_id, String)
    check(room_id, String)
    @update({_id: room_id}, $addToSet: 'user_ids': user_id)

  @leave_room = (user_id, room_id) ->
    check(user_id, String)
    check(room_id, String)
    @update({_id: room_id}, $pull: 'user_ids': user_id)

  @boot_users = (user_ids) ->
    check(user_ids, [String])
    @update({}, $pull: 'user_ids': $in: user_ids)
