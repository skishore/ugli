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

