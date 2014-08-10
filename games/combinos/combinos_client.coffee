SYNC_ICON_HTML = '&middot;&middot;&middot;'
PLAYERS_PER_ROW = 3


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
    @one_row = @view.max_players <= PLAYERS_PER_ROW
    if @view.game_type != 'singleplayer'
      @timer = new CombinosTimer (@send.bind @), @container, @one_row
    # Create separate containers for our board and opponent boards.
    @my_container = $('<div>').addClass 'my-container'
    row_class = if @one_row then 'one-row' else 'two-rows'
    @opponent_container = $('<div>').addClass "opponent-container #{row_class}"
    @container.append @my_container, @opponent_container
    # Update the UI based on the initial view.
    @handle_update @view

  handle_update: (view) ->
    for player, data of view.boards
      if player of @boards
        @boards[player].deserialize data
        if @boards[player].serverSyncIndex == @boards[player].syncIndex
          @containers[player].addClass 'synced'
      else
        @add_board_for_player player, data
    # Remove games that are no longer there.
    players = (player for player of @boards)
    for player in players
      if player not of @view.boards
        do @containers[player].remove
        delete @containers[player]
        delete @boards[player]

  add_board_for_player: (player, data) ->
    target = $('<div>').addClass 'combinos'
    container = $('<div>').addClass('synced combinos-client').append(
        $('<div>').addClass('player').text(player).append(
            ($('<div>').addClass('sync-icon').html SYNC_ICON_HTML))
        target)
    @add_game_container player, container
    # Construct the appropriate type of board inside the container.
    if player == @me
      send = @send_board_update .bind @, player
      @boards[player] = new combinos.ClientBoard target, data, send
    else
      scale = if @one_row then 0.75 else 0.5
      @boards[player] = new combinos.OpponentBoard scale, target, data
    # Register the new container and fix its height.
    @containers[player] = container
    @fix_container_styles player, container

  add_game_container: (player, container) ->
    if player == @me
      @my_container.prepend container
    else
      @opponent_container.append container

  fix_container_styles: (player, container) ->
    # For whatever reason, Bootstrap's CSS adds 5px of height to each game
    # container, possibly by adding a pseudoelement or something.
    container.height (do container.height) - 5
    # Vertically center the board. Slightly trickier when there are two rows
    # of opponents' boards.
    parent_height = (do container.parent().height)
    height = (do container.outerHeight)
    if player == @me or @one_row
      container.css 'margin-top', Math.floor (parent_height - height)/2
    else
      container.css 'margin-top', Math.floor (parent_height - 2*height)/3

  send_board_update: (player, message) ->
    @containers[player].removeClass 'synced'
    @send message
