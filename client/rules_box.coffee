Template.rules_box.rendered = ->
  Common.ugli_client.make_config_ui(
    $('#rules-box'),
    (rules) ->
      console.log 'Making a new game with rules:', rules
  )
