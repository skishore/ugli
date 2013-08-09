@COUNTDOWN_TIME = 10 * 1000
@COMPOSE_TIME = 30 * 1000
@VOTING_TIME = 30 * 1000
@NUM_WORDS = 30

# helpers

@inv_map = (m) ->
  r = {}
  for k, v of m
    (r[v] ?= []).push k
  r

@get_words_from_text = (text) ->
  (w.toLowerCase() for w in text.match /[A-Za-z']+/g)

@words_from_sentence = (sentence) ->
  (w.match(/^"?([A-Za-z']+)[";:.,?!]*$/)?[1] ? w for w in sentence.toLowerCase().split /\s+/ when w)

@validate_sentence = (words, sentence) ->
  allowed = _.countBy words
  used = _.countBy words_from_sentence sentence
  violations = []
  for w, n of used
    if w not of allowed
      violations.push "Word not allowed: #{w}"
    else if allowed[w] < n
      violations.push "Word used too many times: #{w}"
  [violations.length is 0, used, violations]

