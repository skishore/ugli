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
  64

Template.user_list.users = () ->
  (name: 'skishore' for i in [0...64])

Template.chat_box.messages = () ->
  (sender: 'skishore', message: 'hello' for i in [0...64])

Template.games_list.games = () ->
  (name: 'Game #' + i, owner: 'skishore' for i in [0...16])


Meteor.startup () ->
  Session.set('room_id', Rooms.findOne(name: 'lobby')._id)
  Meteor.call 'create_player', (err, result) ->
    return console.log err if err
    Session.set 'player_id', result
    Meteor.setInterval(() =>
      Meteor.call 'heartbeat', Session.get('player_id'), (err, result) ->
        return console.log err if err
    , 1000)
