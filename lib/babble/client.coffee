# client-side ugli context object (passed to Client constructor):
#   config: read-only game config
#   state: read-only client view of game state
#   send(message):
#     send an arbitrary JSONable message to server's on_client_message method

class @BabbleClient
    @make_config_ui: (container, start_game) ->
        # populate the provided jquery-wrapped div with pre-game config ui.
        # the ui should call start_game(config) with JSONable game parameters
        # that will be passed server.init_state as ugli.config
        container.append(
            $('<button/>').text('GO!!!!').on 'click', -> start_game(num_rounds: 5)
        )

    constructor: (@ugli, @container) ->
        # populate the provided jquery-wrapped div with the game ui.
        @container.append(
            $('<pre class="babble-params"/>')
            $('<input class="babble-sentence"/>')
            $('<button/>').text('submit').on 'click', =>
                ugli.send ['submit_sentence',
                    @container.find('.babble-sentence').val()]
            $('<ul class="babble-submissions"/>').on 'click', 'button', ->
                ugli.send ['vote',
                    $(@).closest('li').find('.babble-submission').text()]
        )
        do @on_update

    on_update: ->
        # called to notify client that ugli.state has changed.
        @container.find('.babble-params').text @ugli.state
        @container.find('.babble-submissions').empty().append((
            $('<li/>').append(
                $('<span class="babble-submission"/>').text s
                $('<button/>').text 'vote'
            ) for s in @ugli.state.sentences ? [])...
        )

