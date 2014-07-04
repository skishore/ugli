class @Hungarian
  constructor: (@cost_matrix) ->
    @n = @cost_matrix.length
    for row in @cost_matrix
      if row.length != @n
        throw new Error "Malforrmed cost_matrix: #{@cost_matrix}"
    @range = [0...@n]
    @matched = 0
    # x_label[x] and y_label[y] are dual variables that always satisfy:
    #   @cost_matrix[x][y] <= x_label[x] + y_label[y]
    @x_label = (0 for x in @range)
    @y_label = (0 for y in @range)
    # x_match[x] is the y that is currently matched with the given x.
    # If x is unmatched, then x_match[x] will equal -1.
    #
    # An edge (x, y) is tight if (@cost x, y) == 0. That is, an edge is tight
    # if the labels on the endpoints of the edge add up to its cost. The
    # matching that we produce will only include tight edges.
    @x_match = (-1 for x in @range)
    @y_match = (-1 for y in @range)
    # Run heuristics to modify cost_matrix. These heuristics do not change
    # the optimal solution, but they may allow our algorithm to converge in
    # less than the worst-case n augmenting iterations on easier inputs.
    do @reduce_cost_matrix
    do @find_greedy_solution
    while @matched < @n
      last_matched = @matched
      do @augment
      if @matched <= last_matched
        throw new Error "Augmentation round did not increase matched!"
      # Uncomment these lines to run tightness checks. They may fail if the cost
      # matrix includes floats, due to numerical issues...
      #for x in @range
      #  if @x_match[x] >= 0 and (@cost x, @x_match[x]) != 0
      #    throw new Error "Matched (#{x}, #{@x_match[x]}) which is not tight!"

  reduce_cost_matrix: =>
    # Get a deep copy of the cost matrix to avoid mutating the original.
    @cost_matrix = (do row.slice for row in @cost_matrix)
    for x in @range
      max_cost = Math.max.apply 0, (@cost_matrix[x][y] for y in @range)
      @cost_matrix[x][y] -= max_cost for y in @range
      @x_label[x] = 0
    for y in @range
      max_cost = Math.max.apply 0, (@cost_matrix[x][y] for x in @range)
      @cost_matrix[x][y] -= max_cost for x in @range
      @y_label[y] = 0
    return

  find_greedy_solution: =>
    for x in @range
      for y in @range
        if @x_match[x] == -1 and @y_match[y] == -1 and (@cost x, y) == 0
          @match x, y
          @matched += 1

  cost: (x, y) =>
    @cost_matrix[x][y] - @x_label[x] - @y_label[y]

  match: (x, y) =>
    @x_match[x] = y
    @y_match[y] = x

  augment: =>
    # An augmentation step consists of searching for a path in the graph of
    # tight edges on which every other edge is included in the matching, but
    # in which the first and last edges are free. Once we find such a path,
    # we can increase the size of our matching by 1 by flipping the matches
    # along it.
    #
    # If we cannot find an augmenting path, this function will change the
    # labels for vertices on slack edges along the path and try again.
    x_in_tree = (false for x in @range)
    y_parent = (-1 for y in @range)
    [root, slack, slack_x] = do @find_root_and_slacks
    x_in_tree[root] = true
    while true
      delta = Infinity
      for y in @range
        if y_parent[y] < 0 and slack[y] < delta
          delta = slack[y]
          delta_x = slack_x[y]
          delta_y = y
      @update_labels delta, x_in_tree, y_parent, slack
      y_parent[delta_y] = delta_x
      if @y_match[delta_y] < 0
        # Augmenting path found, ending with the edge (delta_x, delta_y).
        # We flip all edges along the path.
        cur_y = delta_y
        while cur_y >= 0
          cur_x = y_parent[cur_y]
          next_y = @x_match[cur_x]
          @match cur_x, cur_y
          cur_y = next_y
        @matched += 1
        return
      # We've added a new worker to the BFS tree through the tight edges.
      # We need to adjust slack values as a result.
      x = @y_match[delta_y]
      x_in_tree[x] = true
      for y in @range
        if y_parent[y] < 0
          new_slack = -(@cost x, y)
          if slack[y] > new_slack
            slack[y] = new_slack
            slack_x[y] = x

  find_root_and_slacks: =>
    # Returns a triple (root, slack, slack_x), where root is an unmatched node
    # on the left, slack is the current slack between each y and the root, and
    # slack_x[y] is the x value with the minimum slack for node y.
    for x in @range
      if @x_match[x] < 0
        return [x, (-(@cost x, y) for y in @range), (x for y in @range)]

  update_labels: (delta, x_in_tree, y_parent, slack) =>
    for x in @range
      if x_in_tree[x]
        @x_label[x] -= delta
    for y in @range
      if y_parent[y] < 0
        slack[y] -= delta
      else
        @y_label[y] += delta

  get_final_score: (original_matrix) =>
    result = 0
    for x in @range
      result += original_matrix[x][@x_match[x]]
    result
