Template.main_content.in_game = ->
  Meteor.userId()? and Rooms.findOne(_id: Session.get 'room_id')?.is_game

Template.main_content.logged_in = ->
  Meteor.userId()?
