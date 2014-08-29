# We require alphanumeric usernames so we can use them in game states.
Accounts.validateNewUser (user) ->
  if /[^a-zA-Z0-9]/.test user.username
    throw new Meteor.Error 403, 'Username must be alphanumeric'
  if user.username.length < 4
    throw new Meteor.Error 403, 'Username must have at least 4 characters'
  if user.username.length > 16
    throw new Meteor.Error 403, 'Username must have at most 16 characters'
  true
