# Edit this file to set up UGLI to run your game. To set up a new game
# (say, chess), you should:
#   - Place your game's Javascript/CSS in the folder private/chess
#     (We use the private folder to prevent unnecessary code imports.)
#   - Softlink game to private/chess
#   - Set the name, ugli_client getter, and ugli_server getter here

class @Common
  @title = 'Combinos'
  @ugli_client = -> CombinosClient
  @ugli_server = -> CombinosServer

  # If your game has per-player options, set @ugli_options to your
  # implementation of this class here.
  #@ugli_options = -> CombinosOptions

  # Set an autoremove boolean here to control whether rooms are automatically
  # deleted when the last user leaves. If unset, a dialog will be shown.
  @autoremove = true

  # Set this value to true to allow players who are not hosts to start games.
  @any_player_can_start = true

  # Set a singleplayer_config boolean here to cause there to be a persistent
  # "Play singleplayer" button visible in the menu box.
  @singleplayer_config = {game_type: 'singleplayer'}

  # Set this value to true to keep singleplayer rooms around when users leave.
  @persist_singleplayer_rooms = false

  # The list of game types to show in the high-scores list, in order.
  # Leave this attribute unset if you do not wish to expose high scores.
  #@game_types = ['singleplayer']
