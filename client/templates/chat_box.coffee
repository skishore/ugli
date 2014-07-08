# Keep the chat box scrolled to the bottom unless the user scrolls manually.
chats_were_scrolled = false

are_chats_scrolled = ->
  elt = $ '#chat-message-list'
  not elt.length or (elt[0].scrollTop + elt.height() + 6 >= elt[0].scrollHeight)

scroll_chats = ->
  elt = $ '#chat-message-list'
  not elt.length or elt.scrollTop(elt[0].scrollHeight)

set_chat_id = (game) ->
  Session.set_chat_id (
    if game then (do Session.get_game_id) else (do Session.get_lobby_id))


Template.chat_box.chats = ->
  # Scroll chats when this template is created anew, on login or room change.
  chats_were_scrolled = true
  Chats.find {room_id: do Session.get_chat_id}, {sort: created: 1}

Template.chat_box.game_chat_active = ->
  if (do Session.get_chat_id) == (do Session.get_game_id) then 'active' else ''

Template.chat_box.lobby_chat_active = ->
  if (do Session.get_chat_id) == (do Session.get_lobby_id) then 'active' else ''

Template.chat_box.events
  'click .tabbed-heading a': (e) ->
    set_chat_id ($(e.target).data 'chat') == 'game'

  'keydown #chat-input': (e) ->
    if e.keyCode == 13
      message = $(e.target).val().strip()
      if message
        Meteor.call 'send_chat', (do Session.get_chat_id), message
        $(e.target).val ''

  'scroll #chat-message-list': (e) ->
    # Every time the user scrolls, check if they're at the bottom of the list.
    chats_were_scrolled = do are_chats_scrolled

Template.chat_box.rendered = ->
  if chats_were_scrolled
    do scroll_chats


Meteor.startup ->
  Deps.autorun ->
    set_chat_id do Session.get_in_game

  Deps.autorun ->
    Template.chat_box.chats().observe
      added: (document) ->
        # Scroll chats when a new chat comes in if we were already scrolled.
        if chats_were_scrolled
          Meteor.setTimeout scroll_chats, 0
