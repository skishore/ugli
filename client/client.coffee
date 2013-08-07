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


Template.side_bar.is_logged_in = ->
  Meteor.user()

Template.user_list.num_users = ->
  if not Session.get 'room_id'
    return 0
  Users.find('fields.room_ids': Session.get 'room_id').count()

Template.user_list.users = ->
  if not Session.get 'room_id'
    return []
  Users.find({'fields.room_ids': Session.get 'room_id'}, sort: username: 1)

Template.chat_box.chats = ->
  Session.set 'scroll_chats', true
  Chats.find({room_id: Session.get 'room_id'}, sort: sent: 1)

Template.chat_box.rendered = ->
  if Session.get 'scroll_chats'
    scroll_chats()
    Session.set 'scroll_chats', false

Template.chat_box.events({
  'keydown #chat-input': (e) ->
    if e.keyCode == 13
      message = $(e.target).val().strip()
      if message
        Meteor.call 'send_chat', Session.get('room_id'), message
        $(e.target).val ''
})

are_chats_scrolled = ->
  elt = $ '#message-list'
  not elt.length or elt[0].scrollTop + elt.height() + 1 >= elt[0].scrollHeight

scroll_chats = ->
  elt = $ '#message-list'
  not elt.length or elt.scrollTop(elt[0].scrollHeight)


Template.games_list.games = ->
  (name: 'Game #' + i, owner: 'skishore' for i in [0...16])


Meteor.startup ->
  Meteor.subscribe 'rooms'
  Meteor.subscribe 'users'
  Meteor.subscribe 'chats'

  Deps.autorun ->
    if not Rooms.findOne(_id: Session.get 'room_id')
      Session.set 'room_id', Rooms.get_lobby()?._id

  Deps.autorun ->
    Template.chat_box.chats().observe({
      added: (document) ->
        if are_chats_scrolled()
          Session.set 'scroll_chats', true
    })

  Meteor.setInterval(() =>
    Meteor.call 'heartbeat', (err, result) ->
      return console.log err if err
  , 1000)
