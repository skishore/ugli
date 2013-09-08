Template.main_content.in_game = ->
  Meteor.userId()? and Rooms.get(Session.get 'room_id')?.is_game
