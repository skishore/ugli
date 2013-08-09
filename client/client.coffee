Accounts.ui.config {
  passwordSignupFields: 'USERNAME_AND_OPTIONAL_EMAIL',
}


Meteor.startup ->
  Deps.autorun ->
    if Meteor.userId()?
      Meteor.subscribe 'users'
      Meteor.subscribe 'rooms'

  Deps.autorun ->
    Rooms.find(user_ids: Meteor.userId()).observe
      added: (document) ->
        Session.set 'room_id', document._id

  Deps.autorun ->
    if not Rooms.get(Session.get 'room_id')?
      Session.set 'room_id', Rooms.get_lobby()?._id

  Deps.autorun ->
    # TODO(skishore): This dependency reruns when there are any changes to the
    # room, including (for example) when new  users enter. Restrict it.
    rooms = Rooms.find(user_ids: Meteor.userId()).fetch()
    room_ids = (room._id for room in rooms)
    Meteor.subscribe 'chats', room_ids
    Meteor.subscribe 'game_states', room_ids

  Meteor.setInterval (->
    if Meteor.userId()?
      Meteor.call 'heartbeat', (err, result) ->
        return console.log err if err?
  ), 1000
