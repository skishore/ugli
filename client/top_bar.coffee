Template.top_bar.rooms = ->
  # Return the list Rooms.find(), but sorted with the lobby first.
  lobby = Rooms.get_lobby()
  if not lobby
    return [{name: Common.lobby_name}]
  [lobby].concat(room for room in Rooms.find(
    {user_ids: Meteor.userId()}, sort: name: 1,
  ).fetch() when room._id != lobby._id)

Template.top_bar.selected = ->
  if Meteor.user() and Session.equals('room_id', @_id)
    return 'selected'

Template.top_bar.events({
  'click .room-tab': (e) ->
    Session.set('room_id', $(e.target).data 'room-id')
})
