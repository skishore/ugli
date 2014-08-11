SYNC_ICON_HTML = '&middot;&middot;&middot;'
PLAYERS_PER_ROW = 2


class @CombinosClient extends UGLIClient
  @make_config_ui: (container) ->
    data = {game_types: [], max_players: []}
    for game_type, i in CombinosBase.multiplayer_types
      data.game_types.push
        value: game_type
        label: (do game_type.charAt(0).toUpperCase) + (game_type.slice 1)
        active: if i == 0 then 'active' else undefined
    # Render the template using Meteor's UI.
    template = UI.renderWithData Template.combinos_config_ui, data
    UI.insert template, container[0]
    # Set event handlers for the max_players label.
    set_max_players = (game_type) ->
      max_players = CombinosBase.max_players game_type
      container.find('.max-players').text "#{max_players} players"
    set_max_players CombinosBase.multiplayer_types[0]
    container.find('.game-type label').click (e) ->
      set_max_players do $(@).find('input').val
    # Return a callback that extracts data from the form.
    -> game_type: do container.find('.game-type>.active>input').val

  make_game_ui: ->
    @boards = {}
    @containers = {}
    @opponents = {}
    # Create separate containers for our board and opponent boards.
    @my_container = $('<div>').addClass 'my-container'
    @container.append @my_container
    if not @view.singleplayer
      cls = if @one_row then 'one-row' else 'two-rows'
      @opponent_container = $('<div>').addClass "opponent-container #{cls}"
      @status_ui = new CombinosStatusUI (@send.bind @), @view, @me
      @container.append @opponent_container, @status_ui.container
    # Update the UI based on the initial view.
    @handle_update @view

  set_one_row: (one_row) ->
    if one_row == @one_row
      return
    @one_row = one_row
    scale = if @one_row then 0.75 else 0.5
    for player of @boards
      if player != @me
        @boards[player].set_scale scale
        @containers[player].height 'auto'
        @fix_container_styles player, @containers[player]

  handle_update: (view) ->
    @set_one_row @view.num_players <= PLAYERS_PER_ROW
    @status_ui?.handle_update view
    # Create or update boards for any extant games.
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
      game_type = @view.game_type
      send = @send_board_update.bind @, player
      @boards[player] = new combinos.ClientBoard target, data, game_type, send
    else
      scale = if @one_row then 0.75 else 0.5
      @boards[player] = new combinos.OpponentBoard target, data, scale
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
