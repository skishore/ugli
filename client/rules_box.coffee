Template.rules_box.rendered = ->
  Common.ugli_client.make_config_ui(
    $('#rules-box'),
    (rules) ->
      console.log 'Making a new game with rules:', rules
      Meteor.call 'create_game', (err, result) ->
        return console.log err if err
        console.log result
  )
