class GameUI
  @game_ui_class = 'ugli-game-ui'
  @game_clients = {}

  @get_game_ui_key = (user_id, room_id) ->
    "#{user_id}-#{room_id}"

  @create_game_ui = (key) ->
    elt = $('<div>').addClass("#{@game_ui_class} #{key}")
                    .css('position', 'absolute')
    $('#game-ui-container').append elt
    elt

  @hide_game_ui = ->
    $(".#{@game_ui_class}").css 'left', -10000
    $(".#{@game_ui_class}").css 'top', -10000

  @show_game_ui = (key) ->
    game_ui = $(".#{@game_ui_class}.#{key}")
    offset = $('#main-content').offset()
    game_ui.css 'left', offset.left
    game_ui.css 'top', offset.top
    # Account for 1px borders.
    game_ui.css 'width', $('#main-content').width() - 2
    game_ui.css 'height', $('#main-content').height() - 2

  @update_game_ui = ->
    @hide_game_ui()
    room = Rooms.findOne(_id: Session.get 'room_id')
    if Meteor.userId()? and room?.is_game
      game_state = GameStates.get_current_state Session.get 'room_id'
      if Meteor.user().username in (game_state?.players or [])
        key = @get_game_ui_key Meteor.userId(), Session.get 'room_id'
        if key not of @game_clients
          context = new UGLIClientContext(
            Meteor.userId(),
            Session.get('room_id'),
            game_state.index,
            game_state.players,
            game_state.views[Meteor.user().username],
          )
          container = @create_game_ui key
          @game_clients[key] = new Common.ugli_client context, container
        else
          @game_clients[key].ugli.update(
            game_state.index,
            game_state.players,
            game_state.views,
          )
          @game_clients[key].handle_update()
      @show_game_ui key


$(window).on 'resize', -> GameUI.update_game_ui()

Meteor.startup -> Deps.autorun -> GameUI.update_game_ui()
