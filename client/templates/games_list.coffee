fix_games_list_height = ->
  container = $ '#main-content'
  wrapper = $ '#games-list-wrapper'
  bottom = container.offset()?.top + container.height()
  wrapper.height(bottom - wrapper.offset()?.top - 3)
  width = 0.455*$('#games-list').width() - 12
  $('#games-list .game').width width


Template.games_list.games = ->
  Rooms.find(is_game: true)

Template.games_list.is_member = ->
  Meteor.userId() in @user_ids

Template.games_list.open = ->
  game_state = GameStates.get_current_state @_id
  if game_state?.public_view?.open? then '' else 'disabled="disabled"'

Template.games_list.rendered = ->
  fix_games_list_height()

Template.games_list.events
  'click .join-button': (e) ->
    room_id = $(e.target).data 'room-id'
    Meteor.call 'join_game', room_id, (err, result) ->
      console.log err if err

  'click .leave-button': (e) ->
    room_id = $(e.target).data 'room-id'
    Meteor.call 'leave_game', room_id, (err, result) ->
      console.log err if err


$(window).on 'resize', fix_games_list_height
