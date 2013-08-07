# Client code for the side bar, which includes a user list and chat box.
# Keeps the chat box scrolled to the bottom unless the user scrolls manually.

scroll_chats_on_render = false

are_chats_scrolled = ->
  elt = $ '#message-list'
  not elt.length or elt[0].scrollTop + elt.height() + 1 >= elt[0].scrollHeight

scroll_chats = ->
  elt = $ '#message-list'
  not elt.length or elt.scrollTop(elt[0].scrollHeight)


Template.side_bar.is_logged_in = ->
  Meteor.user()

Template.user_list.num_users = ->
  if not Session.get 'room_id'
    return 0
  Users.find('fields.room_ids': Session.get 'room_id').count()

Template.user_list.users = ->
  if not Session.get 'room_id'
    return []
  Users.find({'fields.room_ids': Session.get 'room_id'}, sort: username: 1)

Template.chat_box.chats = ->
  # Scroll chats when this template is created anew, on login or room change.
  scroll_chats_on_render = true
  Chats.find({room_id: Session.get 'room_id'}, sort: sent: 1)

Template.chat_box.rendered = ->
  if scroll_chats_on_render
    scroll_chats()
    scroll_chats_on_render = false

Template.chat_box.events({
  'keydown #chat-input': (e) ->
    if e.keyCode == 13
      message = $(e.target).val().strip()
      if message
        Meteor.call 'send_chat', Session.get('room_id'), message
        $(e.target).val ''
})


Meteor.startup ->
  Deps.autorun ->
    Template.chat_box.chats().observe({
      added: (document) ->
        # Scroll chats if they were fully scrolled before the update.
        if are_chats_scrolled()
          scroll_chats_on_render = true
    })
