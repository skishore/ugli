EXPLANATIONS = {
  singleplayer: '''
    Clearing rows scores points, but as your score increases,
    so does the size of the blocks you get.
    Get the highest score you can before topping out!
  '''
  multiplayer: '''
    Clearing rows increases the sizes of the blocks your opponent gets.
    Make your opponent top out before you do!
  '''
}


class @CombinosBase
  @description: (game_type) ->
    (do game_type.charAt(0).toUpperCase) + (game_type.slice 1)

  @explanation: (game_type) ->
    EXPLANATIONS[game_type]
