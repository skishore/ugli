# The UGLI framework maintains this client's @ugli member variable, which is
# a read-only client-side game context.
#
# This context stores the following data, all of which is read-only:
#   players: list of users currently in the game
#   view: partial client view of game state
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
      $('<div class="getready"/>')
      $('<div class="compose-cont"/>').append(
        $('<div class="words"/>')
        $('<div style="clear:both"/>').append(
          'Compose a sentence! Your sentence: '
          $('<input class="sentence" size="100"/>')
            .on('input', => @_check_input())
            .on('keyup', (e) => @container.find('.submit').click() if e.keyCode is 13)
          ' '
          $('<button class="submit"/>').text('Submit').on 'click', (e) =>
            e.preventDefault()
            ugli.send ['submit_sentence', @container.find('.sentence').val()]
          $('<div class="violations"/>')
        )
      ).hide()
      $('<div class="submissions-cont"/>').append(
        'Time up! Vote on the submissions: '
        $('<ul class="submissions"/>').on 'click', 'button', ->
          ugli.send ['vote', $(@).closest('li').find('.babble-submission').text()]
      ).hide()
      $('<pre class="params" style="font-size:90%"/>')
    )
    @round_words_shuffled = {}
    @handle_update()

  _check_input: ->
    [valid, used_word_counts, messages] =
        validate_sentence @ugli.view.words, @container.find('.sentence').val()
    @container.find('.submit').toggle valid
    @container.find('.violations')
      .empty()
      .append(($('<div>').text m for m in messages)...)
      .toggle(not valid)
    @container.find('.word').each ->
      e = $(@)
      e.toggleClass 'used', used_word_counts[e.text()]-- > 0

  handle_update: ->
    # called to notify client that ugli.state has changed.
    @container.find('.params').text JSON.stringify @ugli.view, undefined, 2

    @container.find('.getready')
      .text("Get ready for round #{@ugli.view.round}!")
      .toggle(@ugli.view.phase is 'countdown')

    @container.find('.compose-cont').toggle @ugli.view.phase is 'compose'
    if @ugli.view.phase is 'compose'
      words = @round_words_shuffled[@ugli.view.round] ?= _.shuffle @ugli.view.words
      @container.find('.words').empty().append(
        ($('<div class="word">').text(w) for w in words)...
      )

    @container.find('.submissions-cont').toggle @ugli.view.phase is 'voting'
    @container.find('.submissions').empty().append((
      $('<li/>').append(
        $('<span class="submission"/>').text s
        $('<button/>').text 'vote'
      ) for s in @ugli.view.sentences ? [])...
    )

    @_check_input()
