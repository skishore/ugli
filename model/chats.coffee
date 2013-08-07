# This collection stores messages that are local to a room:
#   room_id: room _id
#   sender: string
#   message: string
#   sent: ts

class @Chats extends @Collection
  @collection = new Meteor.Collection 'chats'
  @fields = [
    'room_id',
    'sender',
    'message',
    'sent',
  ]

  @publish: (user_id) ->
    user = Users.findOne(_id: user_id)
    if not user?.fields?.room_ids
      return @find(room_id: Rooms.get_lobby()._id)
    @find(room_id: $in: user.fields.room_ids)

  @send_chat: (user_id, room_id, message) ->
    message = message.strip()
    if message
      user = Users.findOne(_id: user_id)
      if room_id in user?.fields?.room_ids
        @insert(
          room_id: room_id,
          sender: user.username,
          message: message,
          sent: new Date().getTime(),
        )
