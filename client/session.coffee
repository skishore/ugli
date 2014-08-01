# The lobby_id is the _id of the lobby room.
Session.get_lobby_id = ->
  Session.get 'lobby_id'

Session.set_lobby_id = (lobby_id) ->
  if lobby_id?
    check lobby_id, String
  Session.set 'lobby_id', lobby_id

# The game_id is the _id of the current game room the player is in,
# if the player is in a game room, and null otherwise.
Session.get_game_id = ->
  Session.get 'game_id'

Session.set_game_id = (game_id) ->
  if game_id?
    check game_id, String
  Session.set 'game_id', game_id

# True if the user is currently in a game in the PLAYING state.
Session.get_in_game = ->
  Session.get 'in_game'

Session.set_in_game = (in_game) ->
  check in_game, Boolean
  Session.set 'in_game', in_game

# True if the user is currently in a multiplayer game in the PLAYING state.
Session.get_in_multiplayer_game = ->
  Session.get 'in_multiplayer_game'

Session.set_in_multiplayer_game = (in_multiplayer_game) ->
  check in_multiplayer_game, Boolean
  Session.set 'in_multiplayer_game', in_multiplayer_game

# The id of the room that the chat window is currently set to.
Session.get_chat_id = ->
  Session.get 'chat_id'

Session.set_chat_id = (chat_id) ->
  if chat_id?
    check chat_id, String
  Session.set 'chat_id', chat_id

# If the player is in the lobby, the game_list_page is the current page of
# the game list he is seeing (if there are too many to fit on one panel).
Session.get_game_list_page = ->
  Session.get 'game_list_page'

Session.set_game_list_page = (game_list_page) ->
  check game_list_page, Number
  Session.set 'game_list_page', game_list_page

# If the player has selected a game in the game list, this is its id.
Session.get_game_details_id = ->
  Session.get 'game_details_id'

Session.set_game_details_id = (game_details_id) ->
  if game_details_id?
    check game_details_id, String
  Session.set 'game_details_id', game_details_id
