@Common = do ->
  # Top-level constants.
  idle_timeout = 10*1000
  lobby_name = 'Lobby'

  # Prototype overrides.
  if not String.prototype.strip?
    String.prototype.strip = ->
      String(this).replace /^\s+|\s+$/g, ''

  # Helper methods.
  get_uid = ->
    num = '' + Math.floor 1000000*Math.random()
    num + (0 for i in [0...(6 - num.length)]).join ''

  # These are the members of Common that are actually exported.
  get_uid: get_uid
  idle_timeout: idle_timeout
  lobby_name: lobby_name
