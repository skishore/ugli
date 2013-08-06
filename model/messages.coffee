# This collection stores messages that are local to a room:
#   room_id: room _id
#   sender: string
#   message: string
#   sent: ts

class @Messages extends @Collection
  @collection = new Meteor.Collection 'messages'
  @fields = [
    'room_id',
    'sender',
    'message',
    'sent',
  ]
