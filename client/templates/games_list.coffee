fix_games_list_height = ->
  container = $ '#main-content'
  wrapper = $ '#games-list-wrapper'
  bottom = container.offset()?.top + container.height()
  wrapper.height(bottom - wrapper.offset()?.top - 3)
  width = 0.455*$('#games-list').width() - 12
  $('#games-list .game').width width


Template.games_list.games = ->
  Rooms.find(is_game: true)

Template.games_list.rendered = ->
  fix_games_list_height()


$(window).on 'resize', fix_games_list_height
