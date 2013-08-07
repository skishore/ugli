Accounts.ui.config {
  passwordSignupFields: 'USERNAME_AND_OPTIONAL_EMAIL',
}


Template.top_bar.rooms = ->
  # Return the list Rooms.find(), but sorted with the lobby first.
  lobby = Rooms.get_lobby()
  if not lobby
    return []
  [lobby].concat(room for room in Rooms.find(
    {}, sort: name: 1,
  ).fetch() when room._id != lobby._id)

Template.top_bar.selected = ->
  if Meteor.user() and Session.equals('room_id', @_id)
    return 'selected'

Template.top_bar.events({
  'click .room-tab': (e) ->
    Session.set('room_id', $(e.target).data 'room-id')
})


Meteor.startup ->
  Deps.autorun ->
    if Meteor.userId()
      Meteor.subscribe 'users'
      Meteor.subscribe 'rooms'

      Meteor.setInterval(() ->
        Meteor.call 'heartbeat', (err, result) ->
          return console.log err if err
      , 1000)

  Deps.autorun ->
    if not Rooms.findOne(_id: Session.get 'room_id')
      Session.set 'room_id', Rooms.get_lobby()?._id

  Deps.autorun ->
    room_ids = (room._id for room in Rooms.find().fetch())
    Meteor.subscribe 'chats', room_ids
