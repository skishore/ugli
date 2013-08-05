Accounts.ui.config {
  passwordSignupFields: 'USERNAME_AND_EMAIL',
}

Template.user_list.num_users = () ->
  64

Template.user_list.users = () ->
  result = []
  for i in [0...64]
    result.push(
      name: 'skishore',
    )
  result

Template.chat_box.messages = () ->
  result = []
  for i in [0...64]
    result.push(
      sender: 'skishore',
      message: 'hello',
    )
  result

Template.games_list.games = () ->
  result = []
  for i in [0...16]
    result.push(
      name: 'Game #' + i,
      owner: 'skishore',
    )
  result
