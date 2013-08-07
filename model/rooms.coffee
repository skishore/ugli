# This collections stores data about rooms, which can be lobbys,
# singleplayer games, or multiplayer games.
#   name: string
#   user_ids: [user _ids]
#   private: bool
#   invites: [string usernames]
#   rules: dict or null (for lobbies)

class @Rooms extends @Collection
  @collection = new Meteor.Collection 'rooms'
  @fields = [
    'name',
    'user_ids',
    'private',
    'invites',
    'rules',
  ]
  if Meteor.isServer
    @collection._ensureIndex 'name', unique: true

  @publish: (user_id) ->
    check(user_id, String)
    @find(user_ids: user_id)

  @get_lobby = ->
    result = @findOne(name: Common.lobby_name)
    if not result and Meteor.isServer
      @insert(
        name: Common.lobby_name,
        user_ids: [],
        private: false,
        invites: [],
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
