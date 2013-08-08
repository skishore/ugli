# server-side ugli context object:
#   user_ids: read-only list of user_ids currently in the game
#   rules: read-only client-supplied game rules
#   state: mutable game state (persisted after each call)
#   setTimeout(callback, timeout):
#     call callback(ugli) after <timeout> seconds.
#     #TODO: returns a handle that supports .time_left() and .cancel()

inv_map = (m) ->
    r = {}
    for k, v of m
        (r[v] ?= []).push k
    r

is_valid_sentence = (words, sentence) ->
    true #TODO

generate_word_list = ->
    ["foo", "bar"] #TODO

    
client_handlers = {}

start_countdown = (ugli) ->
    ugli.state.phase = "countdown"
    ugli.setTimeout start_compose, COUNTDOWN_TIME

start_compose = (ugli) ->
    ugli.state.phase = "compose"
    ugli.state.submissions = {}
    ugli.state.words = generate_word_list()
    ugli.setTimeout start_voting, COMPOSE_TIME

client_handlers.submit_sentence = (ugli, user_id, sentence) ->
    if ugli.state.phase is "compose" and
            is_valid_sentence ugli.state.words, sentence
        ugli.state.submissions[user_id] = sentence

start_voting = (ugli) ->
    ugli.state.phase = "voting"
    ugli.state.votes = {}
    ugli.setTimeout end_voting, VOTING_TIME

client_handlers.vote = (ugli, user_id, sentence) ->
    if ugli.state.phase is "voting" and
            (sentence of inv_map ugli.state.submissions) and
            (ugli.state.submissions[user_id] isnt sentence)
        ugli.state.votes[user_id] = sentence

end_voting = (ugli) ->
    # scoring
    inv_subs = inv_map ugli.state.submissions
    inv_votes = inv_map ugli.state.votes

    winning_sentences = []
    most_votes = 0
    for s, voters in inv_votes
        if voters.length >= most_votes
            if voters.length > most_votes
                winning_sentences = []
                most_votes = voters.length
            winning_sentences.push s

    if winning_sentences.length is 1
        for uid in inv_votes[winning_sentences[0]]
            ugli.state.scores[uid] += 1

    for sentence, submitters of inv_subs
        sentence_score = inv_votes[sentence].length
        if sentence in winning_sentences
            sentence_score += Math.floor 3 / winning_sentences.length
        submitter_score = Math.floor sentence_score / submitters.length
        for uid in submitters
            ugli.state.scores[uid] += submitter_score

    # end scoring
    if ugli.state.round isnt ugli.config.num_rounds
        ugli.state.round += 1
        start_countdown ugli
    else
        ugli.state.round = ugli.state.phase = null

class @BabbleServer
    @initialize_state: (ugli) ->
        # initialize ugli.state based on ugli.rules or throw if config is invalid.
        ugli.state =
            round: 1
            scores: {}
        start_countdown ugli

    @on_client_message: (ugli, user_id, message) ->
        # called when client calls ugli.send(message)
        [method, args...] = message
        client_handlers[method]?(ugli, user_id, args...)

    @get_user_view: (ugli, user_id) ->
        # generate what client sees as ugli.state
        s = {}
        for prop in ['round', 'phase', 'words', 'scores']
            s[prop] = ugli.state[prop]
        if ugli.state.phase is "voting"
            s.sentences = (s for s of inv_map ugli.state.submissions)
        if ugli.state.phase isnt "voting"
            s.votes = inv_map ugli.state.votes
        if ugli.state.phase not in ["compose", "voting"]
            s.submissions = ugli.state.submissions
        #TODO include current phase remaining time
        s

