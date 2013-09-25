class ConfigUI
  @config_ui_class = 'ugli-config-ui'
  @config_clients = {}
  @last_key = null

  @get_config_ui_key: (room) ->
    if room?.is_game then 'generic-in-game-ui' else 'generic-config-ui'

  @create_config_ui: (key) ->
    elt = $('<div>').attr('id', key).addClass(@config_ui_class)
    $('#config-ui-container').append elt
    elt

  @hide_config_ui: ->
    $(".#{@config_ui_class}").css 'left', -10000
    $(".#{@config_ui_class}").css 'top', -10000

  @show_config_ui: (key) ->
    config_ui = $("##{key}.#{@config_ui_class}")
    offset = $('#config-box').offset()
    config_ui.css 'left', offset.left
    config_ui.css 'top', offset.top

  @update_config_ui: ->
    room = Rooms.get Session.get 'room_id'

    key = @get_config_ui_key room
    if key != @last_key
      @hide_config_ui()
    @last_key = key

    if not room?.is_game
      if key not of @config_clients
        container = @create_config_ui key
        @config_clients[key] = Common.ugli_client().make_config_ui(
          container,
          (config) ->
            Meteor.call 'create_game', config, (err, result) ->
              return console.log err if err?
        )
      @show_config_ui key

$(window).on 'resize', -> ConfigUI.update_config_ui()

Meteor.startup -> Deps.autorun -> ConfigUI.update_config_ui()
