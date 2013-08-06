# name: string
# heartbeat: ts
# room_ids: [room _ids]
# user_id: user _id or null
@Players = new Collection(
  'players',
  ['name', 'heartbeat', 'room_ids', 'user_id'],
  index='name',
)

@using @Players, ->
  retries = 3

  @create_player = () =>
    # Creates a new player and returns its _id.
    room_ids = Rooms.get_initial_room_ids()
    cur_try = 0
    while cur_try < retries
      name = 'guest' + Common.get_uid()
      if not @find(name: name).count()
        return @insert(
          name: name,
          heartbeat: new Date().getTime(),
          room_ids: room_ids,
          user_id: null,
        )
      cur_try += 1
    throw "create_new_player failed after #{retries} tries"

  @heartbeat = (player_id) =>
    @update({_id: player_id},
      $set: heartbeat: new Date().getTime(),
    )

  @remove_old_players = () =>
    remove_time = new Date().getTime() - Common.remove_timeout
    @remove(heartbeat: $lt: remove_time)
