page_key = 'game-list-page'
rows_per_page = 8
page_range = 5

game_clause = state: '$ne': RoomState.LOBBY

clamp = (page, num_pages) ->
  Math.max (Math.min page, num_pages - 1), 0

get_indices = (page, num_pages) ->
  half_range = Math.floor page_range/2
  min = Math.max (Math.min page - half_range, num_pages - page_range), 0
  (i + min for i in [0...page_range] when i + min < num_pages)

get_pagination = (page, num_pages) ->
  result = []
  result.push text: '«', data: 'prev', class: if page == 0 then 'disabled'
  for i in get_indices page, num_pages
    result.push text: i + 1, data: i, class: if i == page then 'active'
  last = page == num_pages - 1
  result.push text: '»', data: 'next', class: if last then 'disabled'
  result


Template.game_list.games = ->
  page = Session.get page_key
  Rooms.find game_clause,
    skip: rows_per_page*page
    limit: rows_per_page

Template.game_list.num_pages = ->
  Math.max (Math.ceil (do Rooms.find(game_clause).count)/rows_per_page), 1

Template.game_list.pagination = ->
  page = Session.get page_key
  num_pages = do Template.game_list.num_pages
  new_page = clamp page, num_pages
  if page != new_page
    Session.set page_key, new_page
  get_pagination new_page, num_pages

Template.game_list.events
  'click ul.pagination li': (e) ->
    page = Session.get page_key
    num_pages = do Template.game_list.num_pages
    new_page =
      if @data == 'prev' then page - 1
      else if @data == 'next' then page + 1
      else @data
    new_page = clamp new_page, num_pages
    if new_page != page
      Session.set page_key, new_page


Deps.autorun ->
  room_id = Session.get 'room_id'
  Session.set page_key, 0
