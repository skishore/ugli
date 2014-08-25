# Simple table that stores a full history of games people have played.
# For singleplayer games, result is of the form {player: ..., score: ...}.
# For multiplayer games, result is a mapping from players -> ranks.

class @GameRecords extends Collection
  @set_schema
    name: 'game_records'
    fields: [
      'created',
      'game_type',
      'result',
    ]

  @record_singleplayer_game: (player, score) ->
    Meteor.users.update {username: player}, {
      $inc: {
        'record.singleplayer.games_played': 1
        'record.singleplayer.high_score': 0
      }
    }
    # Since the current Meteor version of Mongo (2.4.9) does not support
    # the $max operator, we have to use a less-than query.
    Meteor.users.update {
      username: player
      'record.singleplayer.high_score': $lt: score
    }, {
      $set: 'record.singleplayer.high_score': score
    }
    # Insert a record into the full game_records table.
    @insert
      created: new Date
      game_type: 'singleplayer'
      result: {player: player, score: score}

  @record_multiplayer_game: (game_type, ranking) ->
    assert game_type != 'singleplayer', 'Got ranking for singleplayer game'
    assert '.' not in game_type, "Period in game_type: #{game_type}"
    losers = []
    winners = []
    for player, rank of ranking
      (if rank == 1 then winners else losers).push player
    # Record a game lost for each of the losers.
    update = {$inc: {}}
    update.$inc["record.#{game_type}.games_played"] = 1
    update.$inc["record.#{game_type}.games_won"] = 0
    Meteor.users.update {username: $in: losers}, update
    # Record a game won for each of the losers.
    update.$inc["record.#{game_type}.games_won"] = 1
    Meteor.users.update {username: $in: winners}, update
    # Insert a record into the full game_records table.
    @insert {created: new Date, game_type: game_type, result: ranking}
