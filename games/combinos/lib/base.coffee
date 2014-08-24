class @CombinosBase
  # Exhaustive lists of combinos game types.
  @GAME_TYPES = ['singleplayer', 'battle', 'race']
  @MULTIPLAYER_TYPES = @GAME_TYPES.filter (x) -> x != 'singleplayer'

  # Per-game-type configuration constants.
  @DESCRIPTIONS = {
    singleplayer: 'Singleplayer'
    battle: 'Battle'
    race: 'Race'
  }
  @EXPLANATIONS = {
    singleplayer: '''
      Clearing rows scores points,
      but as you play, the size of the blocks you get increases,
      Get the highest score you can before topping out!
    '''
    battle: '''
      Clearing rows increases the sizes of the blocks your opponent gets.
      Score higher than your opponent while attacking them!
    '''
    race: '''
      Face off against up to four other players!
      Score more points than your opponents in the available time.
    '''
  }
  @MAX_PLAYERS = {
    singleplayer: 1
    battle: 2
    race: 5
  }

  # Multiplayer game type configuration constants.
  @BETWEEN_ROUND_DURATION = 1000*15
  @ROUND_DURATIONS = {
    battle: 1000*60*6
    race: 1000*60*6
  }
  @CAN_START_LATE = {
    race: true
  }

  # List of states that a multiplayer game's RoundManager can be in.
  @ROUND_STATES = {
    NOT_STARTED: 0
    WAITING_FOR_TIME: 1
    WAITING_FOR_PLAYERS: 2
    PLAYING: 3
    REVIEW: 4
  }
