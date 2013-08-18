# The UGLI framework maintains this client's @ugli member variable, which is
# an instance of UGLIClientContext.

class @UGLIClient
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

  constructor: (@ugli, @container) ->
    # Constructs game UI inside the given jQuery-wrapped container.
    console.log 'UGLIClient.constructor has not been implemented.'

  _handle_update: (new_ugli) ->
    # Framework's wrapper method around implemenations of handle_update.
    @handle_update new_ugli
    @ugli = new_ugli

  handle_update: (new_ugli) ->
    # Takes a new ugli client context and updates the game UI.
    console.log 'UGLIClient.handle_update has not been implemented.'
