class @CombinosClient extends UGLIClient
  @make_config_ui: (container) ->
    container.html('''
      <div class="form-group form-inline">
        <label for="game-type" class="control-label">Game type:</label>
        <label class="radio-inline">
          <input type="radio" name="game-type"
            checked="checked" value="singleplayer">
          Singleplayer
        </label>
        <label class="radio-inline">
          <input type="radio" name="game-type" value="multiplayer"> Multiplayer
        </label>
      </div>
    ''')
    -> game_type: do container.find('input[name="game-type"]:checked').val

  make_game_ui: ->
    @boards = {}
    @opponents = {}
    @handle_update @view

  handle_update: (view) ->
    for player, data of view.boards
      if player of @boards
        @boards[player].deserialize data
        @opponents[player].deserialize data
      else
        target = $('<div>').addClass 'centered combinos'
        @container.append target
        @boards[player] = new combinos.ClientBoard target, data, @send.bind @

        target = $('<div>').addClass 'centered combinos'
        @container.append target
        @opponents[player] = new combinos.OpponentBoard target, data
