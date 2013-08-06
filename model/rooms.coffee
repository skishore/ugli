# This collections stores data about rooms, which can be lobbys,
# singleplayer games, or multiplayer games.
#   name: string

class @Rooms extends @Collection
  @collection = new Meteor.Collection 'rooms'
  @fields = [
    'name',
  ]
  if Meteor.isServer
    @collection._ensureIndex 'name', unique: true

  @publish: (user_id) ->
    lobby_cursor = @find(name: Common.lobby_name)
    user = Users.findOne(_id: user_id)
    if not user?.fields?.room_ids
      if user
        Users.update({_id: user_id},
          $set: 'fields.room_ids': [@get_lobby()._id],
        )
      return lobby_cursor
    @find(_id: $in: user.fields.room_ids)

  @get_lobby = ->
    @findOne(name: Common.lobby_name)
