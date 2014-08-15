class @CombinosRoundUI
  constructor: (@send, round, @me) ->
    @container = $('<div>').addClass 'combinos-status-ui'
    @timer = $('<div>').addClass 'timer'
    @container.append @timer
    @handle_update round
    @interval = setInterval @tick.bind @, 1000

  tick: ->
    if not $.contains window.document, @container[0]
      return clearInterval @interval
    do @update_timer

  handle_update: (round) ->
    @round = round
    do @update_timer
    @update_status_table @get_status_data round

  update_timer: ->
    time = do new Date().getTime
    if @round.state == CombinosBase.ROUND_STATES.WAITING_FOR_PLAYERS
      time_left = 'Need players...'
    else
      time_left = @format_time (Math.max @round.next_time - time, 0)
    if time_left != @time_left
      @timer.text time_left
      @time_left = time_left
    time_left

  format_time: (time) ->
    seconds = Math.floor time/1000
    seconds_text = '' + (seconds % 60)
    while seconds_text.length < 2
      seconds_text = '0' + seconds_text
    "Time: #{Math.floor seconds/60}:#{seconds_text}"

  get_status_data: (round) ->
    data = {header: 'Current scores', rows: []}
    for player of round.scores
      data.rows.push
        name: player
        score: round.scores[player]
        cls: if player == @me then 'bold' else undefined
    data.rows.sort (a, b) ->
      if a.score == b.score then a.name > b.name else b.score - a.score
    data

  update_status_table: (data) ->
    if _.isEqual data, @status_table_data
      return
    do @container.find('.combinos-status-table').remove
    template = UI.renderWithData Template.combinos_status_table, data
    UI.insert template, @container[0]
    @status_table_data = data
