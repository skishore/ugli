Template.main_content.in_lobby = ->
  Meteor.userId() and Session.equals('room_id', Rooms.get_lobby()?._id)

Template.main_content.logged_in = ->
  Meteor.userId()
