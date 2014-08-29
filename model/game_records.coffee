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
  TOP_N = 10

  @format_high_scores: (game_type, key, clause, top_n, user) ->
    result = ({
      rank: i + 1
      player: row.username
      score: row.record[game_type][key]
      games_played: row.record?[game_type].games_played
    } for row, i in top_n)
    if user?
      # If the player is not a guest, bold their row if they're in the
      # top ten, otherwise append a new row for them.
      for row in result
        if row.player == user.username
          row.bold = 'bold'
          return result
      row = {rank: '-', player: user.username, bold: 'bold'}
      if user.record?[game_type]?
        record = user.record[game_type]
        clause["record.#{game_type}.#{key}"] = {$gt: record[key]}
        row.rank = (Math.max (do (Meteor.users.find clause).count), TOP_N) + 1
        row.score = record[key]
        row.games_played = record.games_played
      else
        row.score = row.games_played = '-'
      result.push row
    result

  @get_high_scores: (game_type, player) ->
    # Build a clause to query by and a list of fields to query for.
    clause = {'profile.guests': null}
    clause["record.#{game_type}"] = {$exists: true}
    fields = {username: 1}
    fields["record.#{game_type}"] = 1
    # Build a sort key that depends on the game type.
    key = if game_type == 'singleplayer' then 'high_score' else 'games_won'
    sort = {}
    sort["record.#{game_type}.#{key}"] = -1
    options = {fields: fields, limit: TOP_N, sort: sort}
    # Get data for the player and for the top ten and merge the two.
    top_n = do (Meteor.users.find clause, options).fetch
    player_clause = {username: player, 'profile.guest': null}
    user = Meteor.users.findOne player_clause, {fields: fields}
    @format_high_scores game_type, key, clause, top_n, user

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
