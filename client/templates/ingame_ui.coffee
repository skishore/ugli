ingame_ui_element = null
ugli_client = null


Template.ingame_ui.game = ->
  Rooms.findOne {_id: do Session.get_room_id}

Template.ingame_ui.game_str = ->
  JSON.stringify Rooms.findOne {_id: do Session.get_room_id}


Template.ingame_ui.rendered = ->
  Session.set 'ingame_ui_rendered', true
  ingame_ui_element = $(@firstNode)


Meteor.startup ->
  Deps.autorun ->
    if do Session.get_in_lobby
      Session.set 'ingame_ui_rendered', false
      ingame_ui_element = null
      ugli_client = null

  Deps.autorun ->
    if Session.get 'ingame_ui_rendered'
      user = do Meteor.user
      room = do Template.ingame_ui.game
      if user? and room? and 'game' of room
        if ugli_client?
          ugli_client._handle_update room
        else
          ugli_client = new (do Common.ugli_client)(
            user, room, ingame_ui_element)
