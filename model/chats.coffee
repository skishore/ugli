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
  if Meteor.isServer
    @collection._ensureIndex 'room_id'

  @publish: (user_id, room_ids) ->
    check(user_id, String)
    check(room_ids, [String])
    # Restrict the user's view of chats to rooms that he is in.
    rooms = Rooms.find(_id: {$in: room_ids}, user_ids: user_id).fetch()
    legal_room_ids = (room._id for room in rooms)
    @find(room_id: $in: legal_room_ids)

  @send_chat: (user_id, room_id, message) ->
    check(user_id, String)
    check(room_id, String)
    check(message, String)
    message = message.strip()
    if message
      user = Users.findOne(_id: user_id)
      room = Rooms.findOne(_id: room_id)
      if user and user_id in room?.user_ids
        @insert(
          room_id: room_id,
          sender: user.username,
          message: message,
          sent: new Date().getTime(),
        )
