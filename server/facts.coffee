admin = {
  skishore: true
}

Facts.setUserIdFilter (user_id) ->
  admin[(Meteor.users.findOne user_id)?.username]
