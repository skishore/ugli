SYNC_ICON_HTML = '&middot;&middot;&middot;'


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
    @containers = {}
    @opponents = {}
    @handle_update @view

  handle_update: (view) ->
    for player, data of view.boards
      if player of @boards
        @boards[player].deserialize data
        if @boards[player].serverSyncIndex == @boards[player].syncIndex
          @containers[player].addClass 'synced'
      else
        target = $('<div>').addClass 'combinos'
        container = $('<div>').addClass('synced combinos-client').append(
            $('<div>').addClass('player').text(player).append(
                ($('<div>').addClass('sync-icon').html SYNC_ICON_HTML))
            target)
        @container.append container
        # Register the new container and construct the board inside it.
        send = @send_board_update .bind @, player
        @boards[player] = new combinos.ClientBoard target, data, send
        @containers[player] = container
        @fix_container_height container

  fix_container_height: (container) ->
    # For whatever reason, Bootstrap's CSS adds 5px of height to each game
    # container, possibly by adding a pseudoelement or something.
    container.height (do container.height) - 5

  send_board_update: (player, message) ->
    @containers[player].removeClass 'synced'
    @send message
