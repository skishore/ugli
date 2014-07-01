class @Common
  @idle_timeout =  10*1000
  @lobby_name = 'Lobby'

  @ugli_client = (game_type) ->
    # TODO(skishore): Multiplex between different game clients here.
    HanabiClient

  @ugli_server = (game_type) ->
    # TODO(skishore): Multiplex between different game servers here.
    HanabiServer
