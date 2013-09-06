@assert = (condition, message) ->
  if not condition
    throw new AssertionError message
