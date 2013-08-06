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


Template.player_list.num_players = () ->
  Players.find(room_ids: Session.get 'room_id').count()

Template.player_list.players = () ->
  Players.find(room_ids: Session.get 'room_id')

Template.chat_box.messages = () ->
  (sender: 'skishore', message: 'hello' for i in [0...64])

Template.games_list.games = () ->
  (name: 'Game #' + i, owner: 'skishore' for i in [0...16])


Meteor.startup () ->
  Deps.autorun () ->
    Meteor.subscribe 'players'
    player_id = Session.get 'player_id'
    if player_id
      Meteor.subscribe 'my_player', player_id
      Meteor.subscribe 'rooms', player_id
      if not Session.get 'room_id'
        Session.set 'room_id', Players.findOne(_id: player_id).room_ids[0]

  Meteor.call 'create_player', (err, result) ->
    return console.log err if err
    Session.set 'player_id', result

  Meteor.setInterval(() =>
    player_id = Session.get('player_id')
    if player_id
      Meteor.call 'heartbeat', Session.get('player_id'), (err, result) ->
        return console.log err if err
  , 1000)
