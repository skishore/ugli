class @UGLIClient
  @make_config_ui: (container, start_game) ->
    # This methods takes container and build config UI in that container.
    #
    # The UI includes some sort of submit button, which, when clicked, calls
    # the start_game callback with the config of the new game.
    #
    # This is a default implementation for a game which does not need config.
    container.append(
      $('<span>').text('Set up a new game here: '),
      $('<button>').addClass('create-button').text('Create').on(
        'click', -> start_game({})
      ),
    )
