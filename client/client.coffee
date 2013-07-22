Template.user_list.num_users = () ->
  64

Template.user_list.users = () ->
  result = []
  for i in [0...64]
    result.push(
      name: "skishore@dropbox.com",
    )
  result

Template.chat_box.messages = () ->
  result = []
  for i in [0...64]
    result.push(
      sender: "skishore@dropbox.com",
      message: "hello",
    )
  result

Template.games_list.games = () ->
  result = []
  for i in [0...64]
    result.push(
      name: "Game #" + i,
      owner: "skishore@dropbox.com",
    )
  result
