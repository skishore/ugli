GAME_UNSTARTED = 'unstarted'
GAME_SHOWING_CARDS = 'showing_cards'
GAME_SHOWING_RESULT = 'showing_result'

SUITS = [0...4]
VALUES = [0...13]

NUMCARDS = 8

class @nCkClient extends UGLIClient
  make_game_ui: ->
    @status_message = $('<div>').addClass('nck-status-message')
    @my_cards = $('<span>').addClass('nck-my-cards')
    @their_cards = $('<span>').addClass('nck-their-state')

    row = (div, text) -> $('<div>').addClass('nck-row').text(text or '').append(div)
    @container.append(
      row(@status_message)
      row(@my_cards, 'Your cards:')
      row(@their_cards, 'Their cards:')
    )

    @handle_update @players, @view

  handle_update: (players, view) ->
    if view.state == GAME_UNSTARTED
      @status_message.text 'Waiting for an opponent...'
      @my_cards.html ''
      @their_cards.html ''
    else
      opponent = @opponent players
      assert opponent? and opponent of players, "Missing opponent #{opponent}"
      @status_message.text "Playing against #{opponent}"
      @my_cards.text view.cards[@me]
      @their_cards.text view.cards[opponent]

  opponent: (players) ->
    (player for player of players when player != @me)[0]
