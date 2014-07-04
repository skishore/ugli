# GrabbleUtil includes a number of static methods that implement the
# constraint logic of grabble.

class @GrabbleUtil
  @Element = Match.Where (x) ->
    check x.source, String
    if x.source == 'free'
      check x.letter, String
      return x.letter.length == 1
    else if x.source == 'stolen'
      [i, j] = x.index
      check i, Number
      check j, Number
      return true
    return false
  @Plan = [[@Element]]

  @count: (string) =>
    result = {}
    for i in [0...string.length]
      result[string[i]] = (result[string[i]] or 0) + 1
    result

  @uncount: (count) =>
    result = []
    for char, num of count
      for i in [0...num]
        result.push char
    result

  @diff: (count1, count2) =>
    # Takes two letter frequency dicts and returns the dict of frequencies in
    # the first minus frequencies in the second.
    #
    # Throws an UGLIClientError if a char is more common in count2 than count1.
    for char, num of count2
      if char not of count1 or count1[char] < num
        throw new UGLIClientError \
            "There are not enough #{char}s among the free and stolen tiles!"
      count1[char] -= num
      if count1[char] == 0
        delete count1[char]
    count1

  @check_word: (word) =>
    # Throw an UGLIClientError if the word is not in the dictionary.
    if false
      throw new UGLIClientError "#{word} is not in the dictionary!"

  @check_inclusions: (made, stolen) =>
    # Throws an UGLICLientError if any word in made is a substring or a
    # superstring of any word in stolen.
    for made_word in made
      for stolen_word in stolen
        if made_word == stolen_word
          throw new UGLIClientError "#{stolen_word} was unchanged!"
        if (stolen_word.indexOf made_word) >= 0
          throw new UGLIClientError "#{stolen_word} contains #{made_word}!"
        if (made_word.indexOf stolen_word) >= 0
          throw new UGLIClientError "#{made_word} contains #{stolen_word}!"

  @check_basic_conditions: (free, made, stolen) =>
    # Throws an UGLIClientError if the play is obviously illegal.
    if not made.length
      throw new UGLIClientError 'Tried to play an empty hand!'
    @check_word word for word in made
    @check_inclusions made, stolen

  @get_minimal_free_matching: (made, free) =>
    # If the made words can be matched up the free letters such that each word
    # contains at least one free letter, returns a minimal such matching.
    # This matching is a list of free letters, one for each word in made.
    # Otherwise, throws UGLIClientError.
    matrix = []
    for i in [0...free.length]
      if i < made.length
        row_for_word = []
        for j in [0...free.length]
          row_for_word.push (if (made[i].indexOf free[j]) >= 0 then 1 else 0)
        matrix.push row_for_word
      else
        matrix.push (0 for j in [0...free.length])
    hungarian = new Hungarian matrix
    if (hungarian.get_final_score matrix) < made.length
      throw new UGLIClientError 'Each new word must contain a free letter!'
    (free[hungarian.x_match[i]] for i in [0...made.length])

  @add_source: (sources, letter, source) =>
    if letter not of sources
      sources[letter] = []
    sources[letter].push source

  @finish_plan: (free, made, stolen, leftover_count, free_matching) =>
    # Messy algorithm that first computes the list of sources that we have for
    # each letter in made, using the data format described in plan_play...
    sources = {}
    for i in [0...stolen.length]
      for j in [0...stolen[i].length]
        @add_source sources, stolen[i][j], {source: 'stolen', index: [i, j]}
    for i in [0...free.length]
      if (leftover_count[free[i]] or 0) > 0
        @add_source sources, free[i], {source: 'free', letter: free[i]}
        leftover_count[i] -= 1
    plan = ([] for word in made)
    # Then, for the one required free letter in each made word, fills that one
    # in in the plan with a free letter...
    for i in [0...made.length]
      for j in [0...made[i].length]
        if made[i][j] == free_matching[i]
          plan[i][j] = do sources[made[i][j]].pop
          continue
    # Then, for every other letter, fills it with any available source.
    for i in [0...made.length]
      for j in [0...made[i].length]
        if not plan[i][j]?
          plan[i][j] = do sources[made[i][j]].pop
    plan

  @plan_play: (free, made, stolen) =>
    # Throws an UGLIClientError if this play is not legal. If the play is legal,
    # returns a list of lists of dicts that implement the play. Each dictionary
    # should have the following keys:
    #   source: either 'free' or 'stolen'
    #   index: either an index into the free list or an pair of indices into the
    #          stolen list (first, the word, then, the character).
    @check_basic_conditions free, made, stolen
    leftover_count = @diff (@count made.join ''), (@count stolen.join '')
    @diff (@count free), leftover_count
    # Check that the made words can be matched with free letters such that each
    # word contains at least one free letter.
    free_matching = @get_minimal_free_matching made, @uncount leftover_count
    plan = @finish_plan free, made, stolen, leftover_count, free_matching
    @check_plan free, made, stolen, plan

  @check_plan: (free, made, stolen, plan) =>
    # Throws an UGLIClientError if this plan is illegal.
    @check_basic_conditions free, made, stolen
    free_count = @count free
    stolen_used = []
    for word in stolen
      stolen_used.push (false for i in [0...word.length])
    num_stolen = 0
    for i in [0...made.length]
      for j in [0...made[i].length]
        step = plan[i][j]
        if step.source == 'free'
          # Check that a) the free letter matches and b) is not already used.
          if made[i][j] != step.letter
            throw new UGLIClientError "Mismatched free letter #{step.letter}!"
          if (free_count[step.letter] or 0) == 0
            throw new UGLIClientError "Used too many free #{step.letter}!"
          free_count[step.letter] -= 1
        else
          # Check that a) the stolen letter matches and b) is not already used.
          [x, y] = step.index
          if made[i][j] != stolen[x][y]
            throw new UGLIClientError "Mismatched stolen letter [#{x}, #{y}]!"
          if stolen_used[x][y]
            throw new UGLIClientError "Reused stolen letter [#{x}, #{y}]!"
          stolen_used[x][y] = true
          num_stolen += 1
    # Check that all stolen letters were used.
    total_stolen = 0
    for word in stolen
      total_stolen += word.length
    if num_stolen != total_stolen
      throw new UGLIClientError "Stole #{total_stolen}, used #{num_stolen}!"
    plan
