Template.rules_box.rendered = ->
  Common.ugli_client.make_rules_ui(
    $('#rules-box'),
    (rules) ->
      Meteor.call 'create_game', rules, (err, result) ->
        return console.log err if err?
  )
