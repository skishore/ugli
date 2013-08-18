class GameUI
  @game_ui_class = 'ugli-game-ui'
  @game_clients = {}
  @last_key = null

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
    user = Meteor.user()
    room = Rooms.get(Session.get 'room_id')
    key = @get_game_ui_key user?._id, room?._id

    # Optimization: do not hide the game UI if we're still in the same game as
    # we were during the last update. This prevents a lot of flickering.
    if key != @last_key
      @hide_game_ui()
    @last_key = key

    if user? and room?.is_game
      game_state = GameStates.get_current_state room._id
      if user._id of (game_state?.user_views or {})
        if key not of @game_clients
          container = @create_game_ui key
          @game_clients[key] = new Common.ugli_client()(
            user, room, game_state, container,
          )
          @game_clients[key].make_game_ui()
        else
          @game_clients[key]._handle_update game_state
      @show_game_ui key


$(window).on 'resize', -> GameUI.update_game_ui()

Meteor.startup -> Deps.autorun -> GameUI.update_game_ui()
