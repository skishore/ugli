game_ui_class = 'ugli-game-ui'
rendered_game_ui = {}

in_game = ->
  Meteor.userId() and Session.get('room_id') and not in_lobby()

in_lobby = ->
  Meteor.userId() and Session.equals('room_id', Rooms.get_lobby()?._id)

hide_game_ui = ->
  $(".#{game_ui_class}").css 'left', -10000
  $(".#{game_ui_class}").css 'top', -10000

show_game_ui = (room_id) ->
  game_ui = $(".#{game_ui_class}.#{room_id}")
  offset = $('#main-content').offset()
  game_ui.css 'left', offset.left
  game_ui.css 'top', offset.top
  # Account for 1px borders.
  game_ui.css 'width', $('#main-content').width() - 2
  game_ui.css 'height', $('#main-content').height() - 2


Template.main_content.in_lobby = in_lobby

Template.main_content.logged_in = ->
  Meteor.userId()

Template.main_content.rendered = ->
  hide_game_ui()
  if in_game()
    room_id = Session.get 'room_id'
    if room_id not of rendered_game_ui
      elt = $('<div>').addClass("#{game_ui_class} #{room_id}")
                      .text(room_id)
                      .css('position', 'absolute')
      $('#game-ui-container').append elt
      rendered_game_ui[room_id] = true
    show_game_ui room_id


$(window).on('resize', ->
  if in_game()
    show_game_ui Session.get 'room_id'
)
