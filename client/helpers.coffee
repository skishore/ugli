UI.registerHelper 'in_game', ->
  do Session.get_in_game

UI.registerHelper 'title', ->
  Common.title


Meteor.startup ->
  document.title = Common.title
