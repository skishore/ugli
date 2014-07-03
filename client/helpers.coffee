UI.registerHelper 'in_lobby', ->
  do Session.get_in_lobby

UI.registerHelper 'title', ->
  Common.title


Meteor.startup ->
  document.title = Common.title
