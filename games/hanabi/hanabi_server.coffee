UNKNOWN = '?'

SUITS = [0...5]
VALUES = [0...5]
COUNTS = 0: 3, 1: 2, 2: 2, 3: 2, 4: 1

BURNS = 2
HINTS = 10
HAND_SIZES = 2: 5, 3: 5, 4: 4, 5: 4

DECK = []
do ->
  for suit in SUITS
    for value in VALUES
      for i in [0...COUNTS[value]]
        DECK.push [suit, value]

DESCRIPTION = 'Standard'
EXPLANATION= '''
You will be able to see everyone's hand but your own.
Cooperate with other players by giving them hints about the suits or values
of cards in their hands.
To win, play out a full stack in each suit.
'''

ORDINALS = ['first', 'second', 'third', 'fourth', 'fifth']
COLORS = ['red', 'orange', 'yellow', 'green', 'blue']


class @HanabiServer extends UGLIServer
  initialize_state: (config) ->
    check config.max_players, Number
    if config.max_players not of HAND_SIZES
      throw new UGLIClientError "Invalid num_players: #{config.max_players}"

    @num_players = config.max_players
    @hand_size = HAND_SIZES[@num_players]

    @deck = _.shuffle DECK
    @discards = []
    @stacks = (-1 for suit in SUITS)
    # Set up seats and deal hands to each seat.
    @seats = (false for i in [0...@num_players])
    @hands = ([] for i in [0...@num_players])
    @knowledge = ([] for i in [0...@num_players])
    for i in [0...@num_players]
      for j in [0...@hand_size]
        @deal_card i
    # Set up some counters and auxilary state.
    @cur_seat = 0
    @burns = BURNS
    @hints = HINTS
    @turns = @num_players
    @final_result = false
    # Some private information used only on the server.
    @seat_history = {}

  get_seat: (player) ->
    seat = @seats.indexOf player
    if seat < 0
      throw new UGLIClientError "#{player} has no seat"
    seat

  get_name: (seat, last) ->
    @seats[seat] or "#{if last then 't' else 'T'}he #{ORDINALS[seat]} player"

  describe_card: (card) ->
    "a#{if card[0] == 1 then 'n' else ''}  #{COLORS[card[0]]} #{card[1] + 1}"

  get_lobby_view: ->
    description: DESCRIPTION
    explanation: EXPLANATION
    open: @seats.some (seat) -> !seat
    max_players: @num_players

  get_player_view: (player) ->
    # The only private view in the game is the view of each player's hand.
    seat = @get_seat player
    hands: (
      (if parseInt(i) == seat then @knowledge[i] else hand) \
      for i, hand of @hands
    )

  get_public_view: ->
    # Values which are constant through the whole game.
    num_players: @num_players
    hand_size: @hand_size
    # Basic game state attributes.
    deck_size: @deck.length
    discards: @discards
    stacks: @stacks
    seats: @seats
    knowledge: @knowledge
    # Return some public counters and auxilary state.
    cur_seat: @cur_seat
    burns: @burns
    hints: @hints
    turns: @turns
    final_result: @final_result

  handle_message: (player, message) ->
    seat = @get_seat player
    if seat != @cur_seat
      throw new UGLIClientError "#{player} tried to play out of turn"
    if message.type not in [
        'discard_card', 'play_card', 'give_suit_hint', 'give_value_hint']
      throw new UGLIClientError "#{player} sent invalid message #{message.type}"

    out_of_cards = not @deck.length
    if message.type == 'discard_card'
      @discard_card seat, message.i
    else if message.type == 'play_card'
      @play_card seat, message.i
    else if message.type == 'give_suit_hint'
      @give_suit_hint seat, message.target, message.suit
    else if message.type == 'give_value_hint'
      @give_value_hint seat, message.target, message.value
    else
      assert false, "Unexpected message type: #{message.type}"

    if out_of_cards
      @turns -= 1
      if @turns == 0 and not @final_result
        @final_result = 'You FAILED! Your team is out of turns.'
    @cur_seat = (@cur_seat + 1) % @num_players

  deal_card: (seat) ->
    assert @hands[seat].length < @hand_size, 'Dealt to full hand'
    if @deck.length > 0
      @hands[seat].push @deck.pop()
      @knowledge[seat].push [UNKNOWN, UNKNOWN]

  drop_card: (seat, i) ->
    assert @hands[seat][i]?, "Invalid hand index #{i}"
    card = @hands[seat].splice(i, 1)[0]
    @knowledge[seat].splice i, 1
    @deal_card seat
    card

  discard_card: (seat, i) ->
    if @hints >= HINTS
      throw new UGLIClientError "#{seat} tried to discard with #{HINTS} hints"
    card = @drop_card seat, i
    @discards.push card
    @hints += 1
    @log_game_message (
        "#{@get_name seat} discarded their #{ORDINALS[i]} card. " +
        "It was #{@describe_card card}.")

  play_card: (seat, i) ->
    card = @drop_card seat, i
    if card[1] == @stacks[card[0]] + 1
      @stacks[card[0]] += 1
      if card[1] == VALUES.length - 1 and @hints < HINTS
        @hints += 1
      if (
        1 for suit, stack of @stacks when stack == VALUES.length - 1
      ).length == SUITS.length
          @final_result = 'You won! All stacks are complete.'
      @log_game_message (
          "#{@get_name seat} played their #{ORDINALS[i]} card. " +
          "It was #{@describe_card card}.")
    else
      @discards.push card
      if @burns > 0
        @burns -= 1
      else
        @final_result = 'You FAILED! Your team burned too many cards.'
      @log_game_message (
          "#{@get_name seat} tried to play their #{ORDINALS[i]} card, " +
          "but it burned. It was #{@describe_card card}.")

  check_hint_target: (seat, target) ->
    if parseInt(seat) == parseInt(target) or not @hands[target]?
      throw new UGLIClientError "Invalid hint target: (#{seat}, #{target})"
    if @hints <= 0
      throw new UGLICLientError "Ran out of hints: (#{seat}, #{target})"

  give_suit_hint: (seat, target, suit) ->
    @check_hint_target seat, target
    if suit not in SUITS
      throw new UGLIClientError "Invalid suit #{suit}"
    if suit not in (card[0] for card in @hands[target])
      throw new UGLIClientError "Empty suit hint #{suit}"
    for i of @hands[target]
      if @hands[target][i][0] == suit
        @knowledge[target][i][0] = suit
    @hints -= 1
    @log_game_message (
        "#{@get_name seat} hinted #{@get_name target, true}'s " +
        "#{COLORS[suit]} cards.")

  give_value_hint: (seat, target, value) ->
    @check_hint_target seat, target
    if value not in VALUES
      throw new UGLIClientError "Invalid value #{value}"
    if value not in (card[1] for card in @hands[target])
      throw new UGLIClientError "Empty value hint #{value}"
    for i of @hands[target]
      if @hands[target][i][1] == value
        @knowledge[target][i][1] = value
    @hints -= 1
    @log_game_message (
        "#{@get_name seat} hinted #{@get_name target, true}'s #{value + 1}s.")

  join_game: (player) ->
    if player of @seat_history
      # The player has sat at this game before. Check if their old seat is open.
      seat = @seat_history[player]
      if not @seats[seat]
        @seats[seat] = player
        return
      throw new UGLIClientError "#{player}'s old seat is taken"
    # The player has not sat at this game before. Check for open seats.
    for seat of @seats
      if not @seats[seat]
        @seat_history[player] = seat
        @seats[seat] = player
        return
    throw new UGLIClientError "#{player} tried to join a full game"

  leave_game: (player) ->
    @seats[@get_seat player] = false
