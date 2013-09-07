class @HanabiClient extends UGLIClient
  make_game_ui: ->
    console.log @players, @view

  handle_update: (players, view) ->
    # Takes a new list of players and a new view and updates the game UI.
    console.log 'HanabiClient.handle_update has not been implemented.'
