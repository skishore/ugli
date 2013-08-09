Template.config_box.rendered = ->
  Common.ugli_client.make_config_ui(
    $('#config-box'),
    (config) ->
      Meteor.call 'create_game', config, (err, result) ->
        return console.log err if err?
  )
