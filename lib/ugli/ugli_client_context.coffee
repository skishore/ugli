# An UGLI client context is passed to UGLI clients on initialization and on
# each game update.
#
# The context stores the following read-only data about the game:
#   players: list of players currently in the game
#   view: immutable view of game state
#   me: which player this client is playing as
#
# In addition, the context provides the following UGLI framework helper methods:
#   send: (message) -> send a message to this game's UGLI server

class @UGLIClientContext
  constructor: (user, room, game_state) ->
    @me = user.username
    @_room_id = room._id
    @_index = game_state.index
    @players = game_state.players
    @view = game_state.user_views[user._id]

  send: (message) ->
    Meteor.call 'send_game_message', @_room_id, message, (err, result) ->
      console.log err if err
