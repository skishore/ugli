UNKNOWN = '?'

SUITS = [0...5]
VALUES = [0...5]
COUNTS = 0: 3, 1: 2, 2: 2, 3: 2, 4: 1

HINTS = 10

SUIT_CLASSES =
  0: 'hanabi-red'
  1: 'hanabi-orange'
  2: 'hanabi-yellow'
  3: 'hanabi-green'
  4: 'hanabi-blue'
  '?': 'hanabi-unknown'

class @HanabiClient extends UGLIClient
  make_game_ui: ->
    spacing = ''
    if @view.num_players < 4
      spacing = ' hanabi-less-than-four-player-spacing'
    else if @view.num_players == 4
      spacing = ' hanabi-four-player-spacing'

    @status_message = $('<div>').addClass 'hanabi-status-message' + spacing
    @counters = $('<div>').addClass 'hanabi-counters'
    @container.append @status_message, @counters

    @seat_rows = []
    for i in [0...@view.num_players]
      @seat_rows.push @make_seat_row(@view.hand_size)
      @container.append @seat_rows[@seat_rows.length - 1]

    @stacks = @make_status_row('Stacks:').addClass 'hanabi-stacks-row' + spacing
    @discards = @make_status_row 'Discards:'
    @container.append @stacks, @discards

    @handle_update @view

  make_seat_row: (hand_size) ->
    seat_row = $('<div>').addClass('hanabi-seat-row')
    player_col = $('<div>').addClass('hanabi-player-col')
    cards_col = $('<div>').addClass('hanabi-cards-col')
    moves_col = $('<div>').addClass('hanabi-moves-col')
    # HACK: Deal with the fifth card taking up extra space.
    if hand_size == 5
      cards_col.addClass 'hanabi-five-card-hand'
      moves_col.addClass 'hanabi-five-card-hand'
    # Store elements in internal state.
    seat_row.player_col = player_col
    seat_row.cards_col = cards_col
    seat_row.moves_col = moves_col
    # Return the final seat row.
    seat_row.append player_col, cards_col, moves_col

  make_status_row: (title) ->
    row = @make_seat_row()
    row.addClass 'hanabi-status-row'
    row.player_col.text title
    row.moves_col.remove()
    row

  handle_update: (view) ->
    cur_player = view.seats[view.cur_seat]

    # Draw status message and counters.
    if view.final_result
      @status_message.text view.final_result
    else if not cur_player
      @status_message.text 'Waiting for a player to join...'
    else
      player_str = if cur_player == @me then "your" else "#{cur_player}'s"
      deck_str = "There are #{view.deck_size} cards left in the deck."
      if view.deck_size == 1
          deck_str = (
            "There is 1 card left in the deck, " +
            "and #{view.turns} turns left after drawing it."
          )
      else if not view.deck_size
        deck_str = "The deck is out! There are #{view.turns} turns left."
        if view.turns == 1
          deck_str = "The deck is out! There is 1 turn left."
      @status_message.text "It is #{player_str} turn. #{deck_str}"
    @counters.text "burns: #{view.burns}, hints: #{view.hints}"

    for seat, player of view.seats
      seat_row = @seat_rows[seat]

      seat_row.player_col.text player or '<empty seat>'
      if parseInt(seat) == view.cur_seat
        seat_row.player_col.addClass('hanabi-cur-seat')
      else
        seat_row.player_col.removeClass('hanabi-cur-seat')
      seat_row.cards_col.html ''
      for i, card of view.hands[seat]
        knowledge = if player == @me then undefined else view.knowledge[seat][i]
        seat_row.cards_col.append @draw_card card, knowledge
      # Draw the move options, if it is our turn.
      seat_row.moves_col.html ''
      if cur_player == @me and not view.final_result
        @draw_moves seat, player, view.hands[seat], view.hints, seat_row.moves_col

    # Draw the stacks and discards.
    @stacks.cards_col.html ''
    for suit, value of view.stacks
      if value >= 0
        @stacks.cards_col.append @draw_card [suit, value]
    @discards.cards_col.html ''
    for card in view.discards
      @discards.cards_col.append @draw_card card

  draw_card: (card, knowledge) ->
    suit_class = SUIT_CLASSES[card[0]]
    value_str = if card[1] == UNKNOWN then card[1] else '' + (card[1] + 1)
    card = $('<div>').addClass("hanabi-card #{suit_class}").text value_str
    if knowledge
      if knowledge[0] != UNKNOWN
        card.addClass('hanabi-suit-known')
      if knowledge[1] != UNKNOWN
        card.addClass('hanabi-value-known')
    card

  draw_moves: (seat, player, cards, hints, moves_col) ->
    if player == @me
      moves_col.append $('<span>').text 'Play: '
      for i, card of cards
        button = $('<button>').text(parseInt(i) + 1).click do (i) =>
          => @send type: 'play_card', i: parseInt(i)
        moves_col.append button
      if hints < HINTS
        moves_col.append $('<span>').text ', or discard: '
        for i, card of cards
          button = $('<button>').text(parseInt(i) + 1).click do (i) =>
            => @send type: 'discard_card', i: parseInt(i)
          moves_col.append button
    else if hints > 0
      moves_col.append $('<span>').text 'Reveal: '
      for suit in SUITS
        if (card for card in cards when card[0] == suit).length
          button = $(
              "<button class='#{SUIT_CLASSES[suit]} hanabi-no-padding'>" +
              "&nbsp;&nbsp;</button>"
          ).click do (suit) =>
            => @send type: 'give_suit_hint', target: seat, suit: suit
          moves_col.append button
      moves_col.append $('<span>').text ', or: '
      for value in VALUES
        if (card for card in cards when card[1] == value).length
          value_str = "#{parseInt(value) + 1}s"
          button = $('<button>').text(value_str).click do (value) =>
            => @send type: 'give_value_hint', target: seat, value: value
          moves_col.append button
