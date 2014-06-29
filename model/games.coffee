# This collection stores data about games which can be joined from the lobby.
#   room_id: string
#   room_name: string
#   creator: string
#   description: string
#   state: string
#   num_players: number
#   max_players: number

class @Games extends Collection
  @set_schema
    name: 'games'
    fields: [
      'room_id',
      'room_name',
      'creator',
      'description',
      'state',
      'num_players',
      'max_players',
    ]

  @publish: (user_id) ->
    do @find

  @create_test_data: ->
    @remove {}
    for i in [0...100]
      @insert
        room_id: 'test'
        room_name: RoomNames.data[i]
        creator: 'skishore'
        description: 'Sprint 100-200'
        state: 'Waiting'
        num_players: 3
        max_players: 4
