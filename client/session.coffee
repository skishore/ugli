Session.get_room_id = ->
  Session.get 'room_id'

Session.set_room_id = (room_id) ->
  if room_id?
    check room_id, String
  Session.set 'room_id', room_id

Session.get_in_lobby = ->
  Session.get 'in_lobby'

Session.set_in_lobby = (in_lobby) ->
  check in_lobby, Boolean
  Session.set 'in_lobby', in_lobby

Session.get_game_list_page = ->
  Session.get 'game_list_page'

Session.set_game_list_page = (game_list_page) ->
  check game_list_page, Number
  Session.set 'game_list_page', game_list_page

Session.get_game_details_id = ->
  Session.get 'game_details_id'

Session.set_game_details_id = (game_details_id) ->
  if game_details_id?
    check game_details_id, String
  Session.set 'game_details_id', game_details_id
