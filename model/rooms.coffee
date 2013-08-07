# This collections stores data about rooms, which can be lobbys,
# singleplayer games, or multiplayer games.
#   name: string
#   invite_ids: [list of user _ids]
#   max_size: int or null
#   member_ids: [list of user _ids]
#   private: bool
#   rules: dict or null (for lobbies)

class @Rooms extends @Collection
  @collection = new Meteor.Collection 'rooms'
  @fields = [
    'name',
    'invited_ids',
    'max_size',
    'member_ids',
    'private',
    'rules',
  ]
  if Meteor.isServer
    @collection._ensureIndex 'name', unique: true

  @publish: (user_id) ->
    lobby_cursor = @find(name: Common.lobby_name)
    user = Users.findOne(_id: user_id)
    if not user?.fields?.room_ids
      if user
        @join_room(@get_lobby(), user)
      return lobby_cursor
    @find(_id: $in: user.fields.room_ids)

  @get_lobby = ->
    result = @findOne(name: Common.lobby_name)
    if not result and Meteor.isServer
      @insert(
        name: Common.lobby_name,
        invited_ids: [],
        max_size: null,
        member_ids: [],
        private: false,
        rules: null,
      )
      result = @findOne(name: Common.lobby_name)
    result

  @join_room = (room, user) ->
    # Adds a user to a room's list of members and the room to the user's.
    @update({_id: room._id},
      $addToSet: 'member_ids': user._id,
    )
    Users.update({_id: user._id},
      $addToSet: 'fields.room_ids': room._id,
    )

  @leave_room = (room, user) ->
    # The inverse operation to join_room.
    Users.update({_id: user._id},
      $pull: 'fields.room_ids': room._id,
    )
    @update({_id: room._id},
      $pull: 'member_ids': user._id,
    )
