make_callback = (handler, action) ->
  (e) ->
    if handler.hide action
      do BaseModal.hide


class @BaseModal
  @show: (handler, header, body, buttons) ->
    @header.text header
    (do @body.empty).append body
    do @footer.empty
    for button in buttons
      button_elt = $('<a>')
          .addClass('btn btn-sm')
          .addClass(button.class)
          .text(button.text)
          .click(make_callback handler, button.action)
      @footer.append button_elt
    @modal.modal 'show'

  @hide: ->
    do @header.empty
    do @body.empty
    do @footer.empty
    @modal.modal 'hide'


Template.base_modal.rendered = ->
  BaseModal.modal = $('#base-modal')
  BaseModal.header = BaseModal.modal.find '.modal-header h4'
  BaseModal.body = BaseModal.modal.find '.modal-body'
  BaseModal.footer = BaseModal.modal.find '.modal-footer'
