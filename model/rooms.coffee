# name: string
@Rooms = new Collection('rooms', ['name'], 'name')

@using @Rooms, ->
