# Error pseudo-classes. Usage:
#   throw UGLIModelError 'Details about illegal model call go here.'

traceback = ->
  # Strip out the first four lines, which are tracebacks from the
  # exception function / register_ugli_error / stack calls.
  stack_lines = new Error().stack.split '\n'
  stack_lines.splice(3).join '\n'

register_error = (type) ->
  @[type] = (message) -> "#{type}(\"#{message}\")\n#{traceback()}"

register_error 'NotImplementedError'
register_error 'UGLIConfigurationError'
register_error 'UGLIModelError'
register_error 'UGLIPermissionsError'
