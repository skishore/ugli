# The UGLI framework maintains this client's @ugli member variable, which is
# a read-only client-side game context.
#
# This context stores the following data, all of which is read-only:
#   players: list of users currently in the game
#   state: partial client view of game state
#
# In addition, the context provides these UGLI framework helper methods:
#   send: (message) -> send EJSON-able message to server's handle_client_message

class @BabbleClient
  @make_config_ui: (container, start_game) ->
    # populate the provided jquery-wrapped div with pre-game config ui.
    # the ui should call start_game(config) with JSON-able game parameters
    # that will be passed server.initialize_state.
    container.append(
      'Number of rounds: '
      $ '<input type="number" min="1" max="20" value="5"/>'
      ' '
      $('<button/>').text('Play!').on 'click', ->
        start_game num_rounds: parseInt container.find('input').val()
    )

    constructor: (@ugli, @container) ->
      # populate the provided jquery-wrapped div with the game ui.
      @container.append(
        $('<pre class="babble-params"/>')
        'Submit sentence: '
        $('<input class="babble-sentence"/>')
        ' '
        $('<button/>').text('submit').on 'click', =>
          ugli.send ['submit_sentence',
            @container.find('.babble-sentence').val()]
        'Submissions: '
        $('<ul class="babble-submissions"/>').on 'click', 'button', ->
          ugli.send ['vote',
            $(@).closest('li').find('.babble-submission').text()]
      )
      # TODO(skishore): Does this need to be async?
      do @handle_update

    handle_update: ->
      # called to notify client that ugli.state has changed.
      @container.find('.babble-params').text JSON.stringify @ugli.state
      @container.find('.babble-submissions').empty().append((
        $('<li/>').append(
          $('<span class="babble-submission"/>').text s
          $('<button/>').text 'vote'
        ) for s in @ugli.state.sentences ? [])...
      )
