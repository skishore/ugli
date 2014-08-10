class @CombinosTimer
  constructor: (@send, @container, @one_row) ->
    @element = $('<div>').addClass 'combinos-timer'
    @element.text 'Time: 2:00'
    @container.append @element
