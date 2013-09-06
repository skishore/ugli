GAME_UNSTARTED = 'unstarted'
GAME_STARTED = 'started'

class @nCkClient extends UGLIClient
  make_game_ui: ->
    @status_message = $('<div>').addClass('nck-status-message')
    @my_cards = $('<div>').addClass('nck-my-cards')
    @their_cards = $('<div>').addClass('nck-their-state')

    row = (div) -> $('<div>').addClass('nck-row').append(div)
    @container.append row(@status_message), row(@my_cards), row(@their_cards)

    @handle_update @players, @view

  handle_update: (players, view) ->
    if view.state == GAME_UNSTARTED
      @status_message.text 'Waiting for an opponent...'
      @my_cards.html ''
      @their_cards.html ''
    else
      opponent = @opponent players
      assert opponent? of players, "Missing opponent #{opponent}"
      @status_message.text "Playing against #{opponent}"
      @my_cards.text view.cards[@me]
      @my_cards.text view.cards[opponent]

  opponent: (players) ->
    (player for player of players when player != @me)[0]
