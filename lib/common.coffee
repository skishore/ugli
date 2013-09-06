class @Common
  @idle_timeout =  10*1000
  @keep_history = false
  @lobby_name = 'Lobby'

  @ugli_client = (game_type) ->
    # TODO(skishore): Multiplex between different game clients here.
    nCkClient

  @ugli_server = (game_type) ->
    # TODO(skishore): Multiplex between different game clients here.
    nCkServer

  @get_random_id = ->
    # These ids are NOT necessarily unique! They're only used for naming rooms.
    uid = '' + Math.floor 1000000*Math.random()
    while uid.length < 6
      uid = '0' + uid
    uid
