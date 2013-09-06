class @GhostServer extends UGLIServer
  initialize_state: (config) ->
    # Initialize @state based on config, or throw an UGLIClientError if config
    # is invalid.
    console.log 'GhostServer.constructor has not been implemented.'

  get_player_view: (player) ->
    # Return the view of the game that the given player should see right now.
    #
    # The default implementation makes the entire state visible.
    return @state

  get_public_view: ->
    # Return the view of the game that users in the lobby should see. Certain
    # attributes of this view are handled specially:
    #   open: bool - used to determine whether the join buttons are enabled
    #
    # The default implementation sets open to true.
    return open: true

  handle_message: (player, message) ->
    # Called when a client calls @ugli.send message.
    console.log 'GhostServer.handle_message has not been implemented.'

  join_game: (player) ->
    # Called when a new player wants to join this game. This method should
    # throw an UGLIClientError if the player is not allowed to join.
    #
    # By default, all requests to join are accepted.
    console.log 'GhostServer.join_game has not been implemented.'

  leave_game: (player) ->
    # Called when a player leaves this game. The leave cannot be canceled,
    # so this method should never throw an exception.
    console.log 'GhostServer.leave_game has not been implemented.'
