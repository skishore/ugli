PLAYERS = 5
UNKNOWN = '?'

SUITS = [0...5]
VALUES = [0...5]
COUNTS = 0: 3, 1: 2, 2: 2, 3: 2, 4: 1

BURNS = 2
HINTS = 10
HAND_SIZE = 4

DECK = []
do ->
  for suit in SUITS
    for value in VALUES
      for i in [0...COUNTS[value]]
        DECK.push [suit, value]

class @HanabiServer extends UGLIServer
  initialize_state: (config) ->
    @state.deck = _.shuffle DECK
    @state.discards = []
    @state.stacks = (-1 for suit in SUITS)
    # Set up seats and deal hands to each seat.
    @state.seats = (false for i in [0...PLAYERS])
    @state.hands = ([] for i in [0...PLAYERS])
    @state.knowledge = ([] for i in [0...PLAYERS])
    for i in [0...PLAYERS]
      for j in [0...HAND_SIZE]
        @deal_card i
    # Set up some counters and auxilary state.
    @state.cur_seat = 0
    @state.burns = BURNS
    @state.hints = HINTS
    @state.final_result = false

  get_seat: (player) ->
    seat = @state.seats.indexOf player
    if seat < 0
      throw new UGLIClientError "#{player} has no seat"
    seat

  get_player_view: (player) ->
    seat = @get_seat player
    hands_view = (
      (if parseInt(i) == seat then @state.knowledge[i] else hand) \
      for i, hand of @state.hands
    )

    deck_size: @state.deck.length
    discards: @state.discards
    stacks: @state.stacks
    seats: @state.seats
    hands: hands_view
    # Return some public counters and auxilary state.
    cur_seat: @state.cur_seat
    burns: @state.burns
    hints: @state.hints
    final_result: @state.final_result

  get_public_view: ->
    return open: (player for player of @players).length < 5

  handle_message: (player, message) ->
    seat = @get_seat player
    if seat != @state.cur_seat
      throw new UGLIClientError "#{player} tried to play out of turn"
    if message.type == 'discard_card'
      @discard_card seat, message.i
    else if message.type == 'play_card'
      @play_card seat, message.i
    else if message.type == 'give_suit_hint'
      @give_suit_hint seat, message.target, message.suit
    else if message.type == 'give_value_hint'
      @give_value_hint seat, message.target, message.value
    else
      throw new UGLIClientError "#{player} sent invalid message #{message.type}"
    @state.cur_seat = (@state.cur_seat + 1) % PLAYERS


  deal_card: (seat) ->
    assert @state.hands[seat].length < HAND_SIZE, 'Dealt to full hand'
    if @state.deck.length > 0
      @state.hands[seat].push @state.deck.pop()
      @state.knowledge[seat].push [UNKNOWN, UNKNOWN]

  drop_card: (seat, i) ->
    assert @state.hands[seat][i]?, "Invalid hand index #{i}"
    card = @state.hands[seat].splice(i, 1)[0]
    @state.knowledge[seat].splice i, 1
    @deal_card seat
    card

  discard_card: (seat, i) ->
    if @state.hints >= HINTS
      throw new UGLIClientError "#{seat} tried to discard with #{HINTS} hints"
    @state.discards.push @drop_card seat, i
    @state.hints += 1

  play_card: (seat, i) ->
    card = @drop_card seat, i
    if card[1] == @state.stacks[card[0]] + 1
      @state.stacks[card[0]] += 1
      if card[1] == VALUES.length - 1 and @state.hints < HINTS
        @state.hints += 1
      for suit in SUITS
        if @state.stacks[suit] == VALUES.length - 1
          @state.final_result = 'You won! All stacks are complete.'
    else if @state.burns > 0
      @state.discards.push card
      @state.burns -= 1
    else
      @state.final_result = 'You FAILED! Your team burned too many cards.'

  check_hint_target: (seat, target) ->
    if parseInt(seat) == parseInt(target) or not @state.hands[target]?
      throw new UGLIClientError "Invalid hint target: (#{seat}, #{target})"
    if @state.hints <= 0
      throw new UGLICLientError "Ran out of hints: (#{seat}, #{target})"

  give_suit_hint: (seat, target, suit) ->
    @check_hint_target seat, target
    if suit not in SUITS
      throw new UGLIClientError "Invalid suit #{suit}"
    if suit not in (card[0] for card in @state.hands[target])
      throw new UGLIClientError "Empty suit hint #{suit}"
    for i of @state.hands[target]
      if @state.hands[target][i][0] == suit
        @state.knowledge[target][i][0] = suit
    @state.hints -= 1

  give_value_hint: (seat, target, value) ->
    @check_hint_target seat, target
    if value not in VALUES
      throw new UGLIClientError "Invalid value #{value}"
    if value not in (card[1] for card in @state.hands[target])
      throw new UGLIClientError "Empty value hint #{value}"
    for i of @state.hands[target]
      if @state.hands[target][i][1] == value
        @state.knowledge[target][i][1] = value
    @state.hints -= 1

  join_game: (player) ->
    if (other for other of @players).length >= 5
      throw new UGLIClientError "#{player} tried to join a full game"
    for seat of @state.seats
      if not @state.seats[seat]
        @state.seats[seat] = player
        return
    assert false, "Could not find open seat: #{@state.seats}"

  leave_game: (player) ->
    @state.seats[@get_seat player] = false
