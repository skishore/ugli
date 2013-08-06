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

  @lobby_name = 'Lobby'

  @get_lobby = ->
    @findOne(name: @lobby_name)
