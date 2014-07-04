class @GrabbleClient extends UGLIClient
  @make_config_ui: (container) ->
    container.append $('<span>').text('Click to play a game of grabble!')
    -> {}

  make_game_ui: ->
    @reset @view

  reset: (view) ->
    console.log 'Got new view', view
    do @container.empty
    # Build the interactive UI elements.
    @container.append $('<button>').click @send.bind @, {type: 'flip_letter'}
    input_callback = @make_play.bind @
    text_input = $('<input type="text">').keydown (e) ->
      if e.keyCode == 13
        input_callback do $(e.target).val
    @container.append text_input
    for i in [0...view.players.length]
      @container.append @make_player_row view.players[i], view.words[i]
    for free_letter in view.free_letters
      @container.append $('<h4>').text free_letter

  make_player_row: (player, words) ->
    row = $('<div>')
    row.append $('<div>').text player
    for word in words
      row.append $('<span>').text word
    row

  handle_update: (view) ->
    @reset view

  make_play: (input) ->
    make = input
    steal = ''
    split = input.indexOf '/'
    if split >= 0
      make = input.substr 0, split
      steal = input.substr split + 1
    words_to_make = (word for word in (make.split ' ') when word.length > 0)
    words_to_steal = (word for word in (steal.split ' ') when word.length > 0)
    plan = GrabbleUtil.plan_play \
      @view.free_letters, words_to_make, words_to_steal
    @send
      type: 'make_play',
      words_to_make: words_to_make
      words_to_steal: words_to_steal
      plan: plan
