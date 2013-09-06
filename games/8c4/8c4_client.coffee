class @8c4Client extends UGLIClient
  @make_config_ui: (container, start_game) ->
    # Constructs config UI inside the given jQuery-wrapped container.
    #
    # The UI should include a submit button, which, when clicked, calls the
    # start_game callback with the config of the new game.
    #
    # The default implementation creates UI for a game which needs no config.
    container.append(
      $('<span>').text('Set up a new game here: '),
      $('<button>').addClass('create-button').text('Create').on(
        'click', -> start_game {}
      ),
    )

  make_game_ui: ->
    # Constructs game UI inside an empty @container.
    console.log '8c4Client.make_game_ui has not been implemented.'

  handle_update: (players, view) ->
    # Takes a new list of players and a new view and updates the game UI.
    console.log '8c4Client.handle_update has not been implemented.'
