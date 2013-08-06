# room_id: room _id
# sender: string
# message: string
# sent: ts
@Messages = new Collection(
  'messages',
  ['room_id', 'sender', 'message', 'sent'],
)

@using @Messages, ->
