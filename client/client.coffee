Accounts.ui.config {
  passwordSignupFields: 'USERNAME_AND_EMAIL',
}


Template.top_bar.rooms = ->
  # Return the list Rooms.find(), but sorted with the lobby first.
  lobby = Rooms.get_lobby()
  if not lobby
    return []
  [lobby].concat(room for room in Rooms.find(
    {}, sort: name: 1,
  ) when room._id != lobby._id)

Template.top_bar.selected = ->
  if Meteor.user() and Session.equals('room_id', @_id)
    return 'selected'

Template.top_bar.events({
  'click .room-tab': (e) ->
    Session.set('room_id', $(e.target).data 'room-id')
})


Template.games_list.games = ->
  (name: 'Game #' + i, owner: 'skishore' for i in [0...16])


Meteor.startup ->
  Meteor.subscribe 'users'
  Meteor.subscribe 'rooms'
  Meteor.subscribe 'chats'

  Deps.autorun ->
    if not Rooms.findOne(_id: Session.get 'room_id')
      Session.set 'room_id', Rooms.get_lobby()?._id

  Meteor.setInterval(() =>
    Meteor.call 'heartbeat', (err, result) ->
      return console.log err if err
  , 1000)
