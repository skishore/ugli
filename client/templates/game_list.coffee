page_key = 'game-list-page'
rows_per_page = 8


Template.game_list.games = ->
  page = Session.get page_key
  Games.find {},
    skip: rows_per_page*page
    limit: rows_per_page

Template.game_list.num_games = ->
  do Games.find().count

Template.game_list.num_pages = ->
  Math.ceil (do Template.game_list.num_games)/rows_per_page

Template.game_list.show_prev_button = ->
  (Session.get page_key) > 0

Template.game_list.show_next_button = ->
  (Session.get page_key) + 1 < do Template.game_list.num_pages

Template.game_list.page = ->
  (Session.get page_key) + 1

Template.game_list.events
  'click .pager .prev-button': (e) ->
    old_page = Session.get page_key
    Session.set page_key, Math.max old_page - 1, 0

  'click .pager .next-button': (e) ->
    old_page = Session.get page_key
    Session.set page_key, Math.max old_page + 1, 0


Deps.autorun ->
  room_id = Session.get 'room_id'
  Session.set page_key, 0
