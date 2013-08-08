game_ui_class = 'ugli-game-ui'
rendered_game_ui = {}
instantiated_game_clients = {}

in_game = ->
  Meteor.userId()? and Session.get('room_id')? and not in_lobby()

in_lobby = ->
  Meteor.userId()? and Session.equals('room_id', Rooms.get_lobby()?._id)

get_game_ui_key = (user_id, room_id) ->
  "#{user_id}-#{room_id}"

hide_game_ui = ->
  $(".#{game_ui_class}").css 'left', -10000
  $(".#{game_ui_class}").css 'top', -10000

show_game_ui = (key) ->
  game_ui = $(".#{game_ui_class}.#{key}")
  offset = $('#main-content').offset()
  game_ui.css 'left', offset.left
  game_ui.css 'top', offset.top
  # Account for 1px borders.
  game_ui.css 'width', $('#main-content').width() - 2
  game_ui.css 'height', $('#main-content').height() - 2

update_game_ui = (room_id, fields) ->
  # Listen on changes on a room and check for updates to its game_state_id.
  if 'game_state_id' of fields
    console.log "Got game state #{fields.game_state_id} for #{room_id}"
    user_id = Meteor.userId()
    state = GameStates.findOne(_id: fields.game_state_id)?.views?[user_id]
    console.log 'State:', state
    key = get_game_ui_key user_id, room_id
    console.log rendered_game_ui
    #if key not of instantiated_game_clients
    #  instantiated_game_clients[key] = 1


Template.main_content.in_lobby = in_lobby

Template.main_content.logged_in = ->
  Meteor.userId()


$(window).on 'resize', ->
  if in_game()
    show_game_ui get_game_ui_key Meteor.userId(), Session.get 'room_id'

Meteor.startup ->
  Deps.autorun ->
    hide_game_ui()
    if in_game()
      # Show the game ui div. If it does not exist, construct it.
      key = get_game_ui_key Meteor.userId(), Session.get 'room_id'
      if key not of rendered_game_ui
        elt = $('<div>').addClass("#{game_ui_class} #{key}")
                        .text(key)
                        .css('position', 'absolute')
        $('#game-ui-container').append elt
        rendered_game_ui[key] = true
      show_game_ui key
      # Listen for changes on the room's game state.
      Rooms.find({_id: Session.get 'room_id'}).observeChanges({
        added: update_game_ui
        changed: update_game_ui
      })
