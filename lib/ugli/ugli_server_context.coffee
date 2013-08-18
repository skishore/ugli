# An UGLI server context is passed to UGLI servers on initialization.
# It represents a complete description of the game's state.
#
# The context stores the following data about the game:
#   players: map from player names -> _ids for players in the game
#   state: mutable view of game state
#
# In addition, the context provides these UGLI framework helper methods:
#   setTimeout: (callback, delay) -> call callback after delay ms
#   clearTimeout: (timeout) -> prevent a timeout's callback from executing

class @UGLIServerContext
  constructor: ->
    @players = {}
    @state = {}

  setTimeout: (callback, delay) ->
    throw type: 'NotImplementedError'

  clearTimeout: (timeout) ->
    throw type: 'NotImplementedError'

  _add_user: (user) ->
    # Called to add users to a context if they are accepted into a game.
    @players[user.username] = user._id

  _remove_user: (user) ->
    # Called to remove users from a context if they leave a game.
    delete @players[user.username]
