# players: a list of player names
# words: a list of lists of words, one for each player
# word_map: a mapping from word to the player who made it
# free_letters: a list of free letters

class @GrabbleServer extends UGLIServer
  initialize_state: (config) ->
    @players = []
    @words = []
    @word_map = {}
    @free_letters = []
    @max_players = 6

  get_lobby_view: ->
    description: 'Hax'
    explanation: 'This implementation of grabble is barely functional.'
    open: @players.length < @max_players
    max_players: @max_players

  get_player_view: (player) ->
    {}

  get_public_view: ->
    players: @players
    words: @words
    word_map: @word_map
    free_letters: @free_letters

  handle_message: (player, message) ->
    if message.type == 'make_play'
      @handle_play player, message
    else if message.type == 'flip_letter'
      index = Math.floor 26*(do Math.random)
      @free_letters.push 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[index]
    else
      throw new UGLIClientError "Invalid message.type: #{message.type}"

  handle_play: (player, message) ->
    check message.words_to_make, [String]
    check message.words_to_steal, [String]
    check message.plan, GrabbleUtil.Plan
    GrabbleUtil.check_plan \
      @free_letters, message.words_to_make, message.words_to_steal, message.plan
    for word in message.words_to_steal
      if word not of @word_map
        throw new UGLIClientError "Can't steal #{word}."
    for word in message.words_to_make
      if word of @word_map
        throw new UGLIClientError "Can't make #{word}."
    @execute player, message

  execute: (player, message) ->
    index = @players.indexOf player
    if index >= 0
      for word in message.words_to_steal
        @drop_word word
      for plan in message.plan
        for element in plan
          if element.source == 'free'
            @drop_free_letter element.letter
      for word in message.words_to_make
        @add_word index, word

  drop_word: (word) ->
    index = @words[@word_map[word]].indexOf word
    assert index >= 0
    @words[@word_map[word]].splice index, 1
    delete @word_map[word]

  drop_free_letter: (letter) ->
    index = @free_letters.indexOf letter
    assert index >= 0
    @free_letters.splice index, 1

  add_word: (index, word) ->
    assert 0 <= index < @players.length
    assert word not of @word_map
    @words[index].push word
    @word_map[word] = index

  join_game: (player) ->
    if @players.length == @max_players
      throw new UGLIClientError 'Tried to join a full game!'
    @players.push player
    @words.push []

  leave_game: (player) ->
    index = @players.indexOf player
    if index >= 0
      # Drop words that the player left behind from the word map.
      for word in @words[index]
        delete @word_map[word]
      # Remove the player and his words.
      @players.splice index, 1
      @words.splice index, 1
