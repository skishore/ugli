capitalize = (game_type) ->
  (do game_type[0].toUpperCase) + (game_type.slice 1)


class @HighScoresModal
  @show: ->
    data = {game_types: []}
    for game_type, i in Common.game_types
      data.game_types.push
        active: if i == 0 then 'active'
        game_type: game_type
        label: capitalize game_type
    # Build and show the high-scores element with the game_type selector.
    @high_scores_elt = high_scores_elt = $('<div>')
    UI.insert (UI.renderWithData Template.high_scores, data), high_scores_elt[0]
    BaseModal.show @, 'High scores', high_scores_elt, [
      {class: 'btn-default', text: 'Ok', action: true}
    ]
    # Set event handlers for when the user clicks on a high scores button.
    high_scores_elt.find('.form-group .btn').click ->
      $(@).addClass('active').siblings().removeClass 'active'
      do HighScoresModal.get_high_scores
    do @get_high_scores

  @hide: (action) ->
    true

  @cleanup: ->
    delete @high_scores_elt
    delete @game_type

  @get_game_type = ->
    do @high_scores_elt.find('.form-group>.active>input').val

  @get_high_scores: ->
    game_type = do @get_game_type
    if game_type == @game_type
      return
    @game_type = game_type
    do @high_scores_elt.find('.spinner').show
    do @high_scores_elt.find('.high-scores-table').remove
    Meteor.call 'get_high_scores', game_type, (err, result) ->
      return console.log err if err?
      HighScoresModal.show_high_scores game_type, result

  @show_high_scores: (game_type, high_scores) ->
    do @high_scores_elt.find('.spinner').hide
    if game_type != @game_type
      return
    data =
      label: capitalize game_type
      key: if game_type == 'singleplayer' then 'High score' else 'Games won'
      high_scores: high_scores
    target = @high_scores_elt.find('.high-scores-body')[0]
    UI.insert (UI.renderWithData Template.high_scores_table, data), target
