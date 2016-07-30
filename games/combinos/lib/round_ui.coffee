RoundStates = CombinosBase.ROUND_STATES
FLASHING_DANGER_TIME = 1000*30
DANGER_TIME = 1000*25


class @CombinosRoundUI
  constructor: (@send, round, @me) ->
    @container = $('<div>').addClass 'combinos-status-ui'
    @timer = $('<div>').addClass 'timer'
    @container.append @timer
    @handle_update round
    @interval = setInterval (@tick.bind @), 1000

  tick: ->
    if not $.contains window.document, @container[0]
      return clearInterval @interval
    if do @update_timer
      @send {type: 'update_round'}

  handle_update: (@round) ->
    do @update_timer
    @update_status_table @get_status_data @round

  update_timer: ->
    # Update the timer text. Returns true if we should try to start the round.
    time = do new Date().getTime
    timer_css_class = ''
    if @round.state == RoundStates.WAITING_FOR_PLAYERS
      timer_str = 'Need players...'
    else
      time_left = (Math.max @round.next_time - time, 0)
      timer_str = @format_time time_left
      if @round.state == RoundStates.PLAYING
        if time_left < DANGER_TIME
          timer_css_class = 'danger'
        else if time_left < FLASHING_DANGER_TIME
          timer_css_class = 'flashing-danger'
      due = time_left <= 0
    if timer_str != @timer_str
      @timer.text timer_str
    if timer_css_class != @timer_css_class
      @timer.removeClass('danger flashing-danger').addClass(timer_css_class)
      @timer_css_class = timer_css_class
    due

  format_time: (time) ->
    seconds = Math.ceil time/1000
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
