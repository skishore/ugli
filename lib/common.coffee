# Edit this file to set up UGLI to run your game. To set up a new game
# (say, chess), you should:
#   - Place your game's Javascript/CSS in the folder private/chess
#     (We use the private folder to prevent unnecessary code imports.)
#   - Softlink game to private/chess
#   - Set the name, ugli_client getter, and ugli_server getter here

class @Common
  @title = 'Hanabi'
  @ugli_client = -> HanabiClient
  @ugli_server = -> HanabiServer
  # Set an autoremove boolean here to control whether rooms are automatically
  # deleted when the last user leaves. If unset, a dialog will be shown.
  #@autoremove = true
  # Set a singleplayer_config boolean here to cause there to be a persistent
  # "Play singleplayer" button visible in the menu box.
  #@singleplayer_config = {max_players: 2}
