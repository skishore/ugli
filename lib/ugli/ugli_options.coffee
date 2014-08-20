# This class can be overridden to prove game-specific options to users.
# These options will only be exposed to the UGLI client, so there are no
# security guarantees for the value. They are stored in the Meteor user's
# profile field, which can be written to without calling a server-side method.

class @UGLIOptions
  @create_options_ui: (container, options) ->
    # Constructs the options UI within the given jQuery-wrapped container.
    #
    # This method is passed the current user options dictionary.
    # Note that this dictionary may not have a complete set of options!
    # If the code of the game changes, it may be an options dict validated
    # by old validation code. Be robust to this possibility.
    #
    # If this user's options have not previously been set, or if the user
    # restores their default options, options will be undefined.
    #
    # This method should return a function that, when called, returns an
    # options dictionary based on the current settings in the UI.
    throw new NotImplementedError 'UGLIOptions.create_options_ui!'

  @validate_options: (options) ->
    # This method should throw an UGLIClientError if the given options are
    # not valid. It is a purely client-side check.
    throw new UGLIClientError "Invalid options: #{JSON.stringify options}"
