# This collection stores messages that are local to a room:
#   room_id: room _id
#   sender: string
#   message: string
#   active: bool
#   created: ts

class @Chats extends Collection
  @set_schema
    name: 'chats'
    durable: Common.durable
    fields: [
      'room_id',
      'sender',
      'message',
      'active'
      'created',
    ]
    indices: [
      {columns: {active: 1, room_id: 1}}
    ]

  @publish: (user_id, room_ids) ->
    check user_id, String
    # Drop the room_ids param and restrict the user's view to rooms he is in.
    rooms = Rooms.get_user_rooms user_id
    legal_room_ids = (room._id for room in rooms)
    @find(active: true, room_id: $in: legal_room_ids)

  @send_chat: (user_id, room_id, message) ->
    check user_id, String
    check room_id, String
    check message, String
    message = message.strip()
    if message
      user = Users.get user_id
      room = Rooms.get room_id
      if user? and room? and user._id in room.user_ids
        @insert
          room_id: room_id
          sender: user.username
          message: message

  @cleanup_orphaned_chats: ->
    rooms = Rooms.find({active: true}, fields: _id: 1).fetch()
    active_room_ids = (room._id for room in rooms)
    @cleanup room_id: $not: $in: active_room_ids
