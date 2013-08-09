class @UGLIClientContext
  constructor: (user, @_room_id, @index, @players, @view) ->
    @_user_id = user._id
    @player = user.username

  update: (index, players, view) ->
    # Update the client context. Return true if the client should be notified.
    if index > @index
      @index = index
      @players = players
      @view = view
      return true
    false

  send: (message) ->
    console.log "#{@_user_id}-#{@_room_id} sent #{message}"
    Meteor.call 'send_game_message', @_room_id, message, (err, result) ->
      console.log err if err
