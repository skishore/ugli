class @CombinosOptions extends UGLIOptions
  @make_options_ui: (container, options) ->
    options = new combinos.Options container, options
    options.get_current_options.bind options

  @validate_options: (options) ->
    combinos.Options.validate_options options
