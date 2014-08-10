class @CombinosStatusUI
  constructor: (@send, view, @me) ->
    @container = $('<div>').addClass 'combinos-status-ui'
    @timer = $('<div>').addClass 'timer'
    @timer.text 'Time: 2:00'
    @container.append @timer
    @handle_update view

  handle_update: (view) ->
    data = {header: 'Current scores', rows: []}
    for player of view.boards
      data.rows.push
        name: player
        score: view.boards[player].score
        cls: if player == @me then 'bold' else undefined
    data.rows.sort (a, b) ->
      if a.score == b.score then a.name > b.name else b.score - a.score
    @update_status_table data

  update_status_table: (data) ->
    if _.isEqual data, @status_table_data
      return
    do @container.find('.combinos-status-table').remove
    template = UI.renderWithData Template.combinos_status_table, data
    UI.insert template, @container[0]
    @status_table_data = data
