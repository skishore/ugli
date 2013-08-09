# server-side ugli context object:
#   players: list of player names
#   state: mutable game state (persisted after each call)
#   setTimeout(callback, timeout):
#     call callback(ugli) after <timeout> milliseconds.


#TODO merge a wikipedia article with a yahoo answers thread
Source = YahooAnswers
generate_word_list = ->
  for key in _.shuffle Source.get_random_articles()
    words = get_words_from_text Source.get_article_content key
    if words.length >= NUM_WORDS
      return _.take(_.shuffle(words), NUM_WORDS).sort()
  throw "couldn't find a good word list"


# game flow logic

client_handlers = {}

start_countdown = (ugli) ->
  ugli.state.phase = "countdown"
  ugli.setTimeout start_compose, COUNTDOWN_TIME

start_compose = (ugli) ->
  ugli.state.phase = "compose"
  ugli.state.submissions = {}
  ugli.state.words = generate_word_list()
  ugli.setTimeout start_voting, COMPOSE_TIME

client_handlers.submit_sentence = (ugli, player, sentence) ->
  if ugli.state.phase is "compose" and
      validate_sentence(ugli.state.words, sentence)[0]
    ugli.state.submissions[player] = sentence

start_voting = (ugli) ->
  ugli.state.phase = "voting"
  ugli.state.votes = {}
  ugli.setTimeout end_voting, VOTING_TIME

client_handlers.vote = (ugli, player, sentence) ->
  if ugli.state.phase is "voting" and
      (sentence of inv_map ugli.state.submissions) and
      (ugli.state.submissions[player] isnt sentence)
    ugli.state.votes[player] = sentence

end_voting = (ugli) ->
  inv_subs = inv_map ugli.state.submissions
  inv_votes = inv_map ugli.state.votes

  # find winning sentence(s)
  winning_sentences = []
  most_votes = 0
  for s, voters in inv_votes
    if voters.length >= most_votes
      if voters.length > most_votes
        winning_sentences = []
        most_votes = voters.length
      winning_sentences.push s

  # award points for voting on the winning sentence
  if winning_sentences.length is 1
    for uid in inv_votes[winning_sentences[0]] ? []
      ugli.state.scores[uid] += 1

  for sentence, submitters of inv_subs
    sentence_score = (inv_votes[sentence] ? []).length
    if sentence in winning_sentences
      sentence_score += Math.floor 3 / winning_sentences.length
    submitter_score = Math.floor sentence_score / submitters.length
    for uid in submitters
      ugli.state.scores[uid] += submitter_score
  # end scoring

  if ugli.state.round isnt ugli.state.num_rounds
    ugli.state.round += 1
    start_countdown ugli
  else
    ugli.state.round = ugli.state.phase = null

class @BabbleServer
  @initialize_state: (ugli, config) ->
    # initialize ugli.state based on config or throw if it is invalid.
    check config.num_rounds, Number
    if config.num_rounds <= 0 or config.num_rounds > 5
      throw "Invalid number of rounds: #{config.num_rounds}"
    ugli.state =
      num_rounds: config.num_rounds
      round: 1
      scores: {}
    start_countdown ugli

  @join_game: (ugli, player) ->
    # A notification that a player wants to join the game. If this method
    # returns false, the player will not be allowed to join.
    return ugli.players.length < 2

  @leave_game: (ugli, player) ->
    # A notification that a player has left the game. No response necessary.

  @handle_client_message: (ugli, player, message) ->
    # called when client calls ugli.send(message)
    [method, args...] = message
    client_handlers[method]?(ugli, player, args...)

  @get_player_view: (ugli, player) ->
    # generate what client sees as ugli.view
    v = {}
    for prop in ['round', 'phase', 'words', 'scores']
      v[prop] = ugli.state[prop] if prop of ugli.state
    if ugli.state.phase is "voting"
      v.sentences = (s for s of inv_map ugli.state.submissions)
    if ugli.state.phase not in ["compose", "voting"]
      v.votes = inv_map ugli.state.votes
      v.submissions = ugli.state.submissions
    #TODO include current phase remaining time?
    v

  @get_public_view: (ugli) ->
    # Generate what all users can see about this game. Certain attributes of the
    # resulting dict are handled specially:
    #   open: bool - used to determine whether users can join this game
    open: ugli.players.length < 2
