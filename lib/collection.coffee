# A class that wraps a collection with some basic schema checking.
# To use this class:
#   1. Create a subclass for the collection you want to wrap.
#   2. Add @collection and @fields static properties to the subclass.
#   3. Optionally add ensureIndex calls and other model calls.

class @Collection
  @collection = null
  @fields = null

  # Some fields will automatically be populated on inserts.
  @default_field_values =
    active: -> true
    created: -> new Date().getTime()

  @_check_fields_exist: (schema) ->
    for key in @fields
      if key not of schema
        if key of @default_field_values
          schema[key] = do @default_field_values[key]
        else
          throw new UGLIModelError "#{@collection._name}: missing key: #{key}"

  @_check_fields_legal: (schema) ->
    for key of schema
      if key not in @fields and key != '_id'
        throw new UGLIModelError "#{@collection._name}: illegal key: #{key}"

  @_check_update: (update) ->
    for key of update
      if key[0] != '$'
        throw new UGLIModelError "#{@collection._name}: illegal update: #{key}"
      @_check_fields_legal update[key]

  @get: (_id) ->
    @collection.findOne _id: _id

  @find: (selector, options) ->
    if selector?
      @_check_fields_legal selector
      return @collection.find selector, options
    @collection.find()

  @findOne: (selector, options) ->
    if selector?
      @_check_fields_legal selector
      return @collection.findOne selector, options
    @collection.findOne()

  @insert: (obj) ->
    @_check_fields_exist obj
    @_check_fields_legal obj
    @collection.insert obj

  @update: (selector, update) ->
    if not selector?
      throw new UGLIModelError 'update called with no selector!'
    @_check_fields_legal selector
    @_check_update update
    @collection.update selector, update, multi: true

  @remove: (selector) ->
    if not selector?
      throw new UGLIModelError 'remove called with no selector!'
    @_check_fields_legal selector
    @collection.remove selector

  @cleanup: (clause) ->
    clause.active = true
    if Common.keep_history
      @update clause, $set: $active: false
    else
      @remove clause
