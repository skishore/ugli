# The room_id is the _id of the current room the player sees chat, a player
# list, and possible the game for.
Session.get_room_id = ->
  Session.get 'room_id'

Session.set_room_id = (room_id) ->
  if room_id?
    check room_id, String
  Session.set 'room_id', room_id

# The in_lobby boolean is true if the player's current room is the lobby.
Session.get_in_lobby = ->
  Session.get 'in_lobby'

Session.set_in_lobby = (in_lobby) ->
  check in_lobby, Boolean
  Session.set 'in_lobby', in_lobby

# The wait_id is the id of a WAITING-state game the player has joined.
Session.get_wait_id = ->
  Session.get 'wait_id'

Session.set_wait_id = (wait_id) ->
  if wait_id?
    check wait_id, String
  Session.set 'wait_id', wait_id

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
