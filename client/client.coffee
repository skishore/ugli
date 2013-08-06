Accounts.ui.config {
  passwordSignupFields: 'USERNAME_AND_EMAIL',
}


Template.top_bar.rooms = () ->
  Rooms.find()

Template.top_bar.selected = () ->
  if @_id == Session.get 'room_id'
    return 'selected'

Template.top_bar.events({
  'click .room-tab': (e) ->
    Session.set('room_id', $(e.target).data 'room-id')
})


Template.user_list.num_users = () ->
  if not Session.get 'room_id'
    return 0
  Users.find('fields.room_ids': Session.get 'room_id').count()

Template.user_list.users = () ->
  if not Session.get 'room_id'
    return []
  Users.find('fields.room_ids': Session.get 'room_id')

Template.chat_box.messages = () ->
  (sender: 'skishore', message: 'hello' for i in [0...64])

Template.games_list.games = () ->
  (name: 'Game #' + i, owner: 'skishore' for i in [0...16])


Meteor.startup () ->
  Deps.autorun () ->
    Meteor.subscribe 'rooms'
    Meteor.subscribe 'users'
    if not Rooms.findOne(_id: Session.get 'room_id')
      Session.set 'room_id', Rooms.get_lobby()?._id

  Meteor.setInterval(() =>
    Meteor.call 'heartbeat', (err, result) ->
      return console.log err if err
  , 1000)
