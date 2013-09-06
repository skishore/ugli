GAME_UNSTARTED = 'unstarted'
GAME_SHOWING_CARDS = 'showing_cards'
GAME_SHOWING_RESULT = 'showing_result'

SUITS = [0...4]
VALUES = [0...13]

NUM_CARDS = 8
NUM_PASS = 4

SUITS_TO_HTML = ['&#9827;', '&#9830;', '&#9829;', '&#9824;']
VALUES_TO_CHARACTERS = 0: 'A', 10: 'J', 11: 'Q', 12: 'K'

class @nCkClient extends UGLIClient
  make_game_ui: ->
    @status_message = $('<div>').addClass('nck-status-message')
    @my_cards = $('<div>').addClass('nck-my-cards')
    @their_cards = $('<div>').addClass('nck-their-cards')
    @error_message = $('<div>').addClass('nck-error-message')
    @cards_round = -1

    row = (elt, text) ->
      result = $('<div>').addClass('nck-row').append elt
      if text
        result.prepend $('<div>').addClass('nck-row-prefix').text text
      result
    @container.append(
      row(@status_message)
      row(@my_cards, 'Your cards:')
      @error_message
      row(@their_cards, 'Their cards:')
    )
    @handle_update @players, @view

  handle_update: (players, view) ->
    if view.state == GAME_UNSTARTED
      @status_message.text 'Waiting for an opponent...'
      @my_cards.html ''
      @their_cards.html ''
      @error_message.html ''
    else
      opponent = @opponent players
      assert opponent? and opponent of players, "Missing opponent #{opponent}"
      if view.state == GAME_SHOWING_CARDS
        if not view.picked[@me]
          message = "Choose four cards to pass to #{opponent}."
          if view.picked[opponent]
            message += " They have picked!"
        else
          message = "Waiting on #{opponent}'s pass..."
      else
        assert view.state == GAME_SHOWING_RESULT, "Invalid state: #{view.state}"
        message = "Showing results skishore fixme!"
        if view.ready[@me]
          message += " Waiting on #{opponent}..."
        else if view.ready[opponent]
          message += " Click 'Next round' to move on."
      @status_message.text message

      # Construct the cards if they have not been constructed for this round.
      if view.round > @cards_round
        @cards_round = view.round
        @draw_cards @my_cards, view.cards[@me]
        @draw_cards @their_cards, view.cards[opponent]
        # Set the event handlers for clicking on cards and for passing.
        @my_cards.find('.nck-card').click do (that=@) -> (e) ->
          if that.view.state == GAME_SHOWING_CARDS and not that.view.my_pick
            $(@).toggleClass 'selected'

      # Create pass button and card selection UI.
      if view.my_pick
        @my_cards.find('.nck-pass-button').remove()
        @my_cards.find('.nck-card').removeClass 'selected'
        for card in @my_cards.find('.nck-card')
          if $(card).data('index') in view.my_pick
            $(card).addClass 'picked'
        if view.state == GAME_SHOWING_RESULT
          for card in @their_cards.find('.nck-card')
            if $(card).data('index') in view.picks[opponent]
              $(card).addClass 'picked'
      else if not @my_cards.find('.nck-pass-button').length
        @my_cards.append $('<button>').addClass('nck-pass-button')
                                      .text('Pass cards').click @pass_cards

      # Create ready button to move to next round.
      if view.state != GAME_SHOWING_RESULT or view.ready[@me]
        @my_cards.find('.nck-next-button').remove()
      else if not @my_cards.find('.nck-next-button').length
        @my_cards.append $('<button>').addClass('nck-next-button')
                                      .text('Next round').click @next_round

  opponent: (players) ->
    (player for player of players when player != @me)[0]

  draw_cards: (cards_elt, cards) ->
    cards_elt.html ''
    for i, card of cards
      cards_elt.append @draw_card i, card

  draw_card: (i, card) ->
    [suit, value] = card
    suit_str = SUITS_TO_HTML[suit]
    value_str = '' + (value + 1)
    if value of VALUES_TO_CHARACTERS
      value_str = VALUES_TO_CHARACTERS[value]
    color = if suit in [1, 2] then 'red' else 'black'
    span = $('<span>').html(suit_str + value_str).css 'color', color
    $('<div>').addClass('nck-card').append(span).data('index', i)

  pass_cards: =>
    if @view.state == GAME_SHOWING_CARDS and not @view.my_pick
      indices = (
        $(elt).data('index') for elt in \
        @my_cards.find('.nck-card.selected')
      )
      if indices.length == 4
        @error_message.html ''
        @send type: 'pick', picked: indices
      else
        @error_message.html 'You must select exactly 4 cards to pass.'

  next_round: =>
    if @view.state == GAME_SHOWING_RESULT
      @send type: 'ready'
