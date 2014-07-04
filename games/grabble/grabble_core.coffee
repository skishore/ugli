# Stores the state of a Grabble game, used on both the client and the server.
#   word_lists: a list of lists of words that people have made
#   word_map: a map from word -> [i, j] s.t. word_lists[i][j] == word
#   free_tiles: a list of free letters

class @GrabbleCore
  constructor: ->
    @word_lists = []
    @word_map = {}
    @free_tiles = []

  add_tile: (tile) =>
    @free_tiles.push tile

  get_first_completion: (prefix) =>
    # Returns the first word among player's words that starts with the prefix.
    words = do (word for word of @word_map).sort
    for word in words
      if words.indexOf prefix == 0
        return word
    null

  letter_counts: (string) =>
    result = {}
    for i in [0...string.length]
      result[string[i]] += 1
    result

  plan_play: (made, stolen) =>
    # Takes a list of words that the user wants to make and a list that the
    # want to steal. Returns true if this play is legal.
    made_counts = @letter_counts made.join ''
    stolen_counts = @letter_counts stolen.join ''
    for char, count of stolen_counts
      if char not of made_counts or made_counts[char] < count
        return false
      made_counts[char] -= count
