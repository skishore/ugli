# This collection stores messages that are local to a room:
#   room_id: room _id
#   sender: string
#   message: string

class @Chats extends Collection
  @set_schema
    name: 'chats'
    fields: [
      'room_id',
      'sender',
      'message',
    ]
    indices: [
      {columns: room_id: 1}
    ]

  @publish: (user_id, room_id) ->
    check user_id, String
    legal_room_id = UGLICore.get_room_id user_id
    if room_id == legal_room_id
      @find room_id: room_id

  @send_chat: (user_id, room_id, message) ->
    check user_id, String
    check room_id, String
    check message, String
    @insert
      room_id: room_id
      sender: user.username
      message: message
