Accounts.validateNewUser (user) ->
  if /[^a-zA-Z0-9]/.test user.username
    throw new Meteor.Error 403, 'Username must be be alphanumeric'
  true
