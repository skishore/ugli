# A class that wraps a collection with some basic schema checking.
# To use this class:
#   1. Create a subclass for the collection you want to wrap.
#   2. Add @collection and @fields static properties to the subclass.
#   3. Optionally add ensureIndex calls and other model calls.

class @Collection
  @collection = null
  @fields = null
  @verbose = false

  # Some fields will automatically be populated on inserts.
  @default_field_values =
    active: -> true
    created: -> new Date().getTime()

  @check_fields_exist: (schema) ->
    for key in @fields
      if key not of schema
        if key of @default_field_values
          schema[key] = do @default_field_values[key]
        else
          console.log "#{@collection._name}: missing key: #{key}"
          throw "#{@collection._name}: missing key: #{key}"

  @check_fields_legal: (schema) ->
    for key of schema
      if key not in @fields and key != '_id'
        console.log "#{@collection._name}: illegal key: #{key}"
        throw "#{@collection._name}: illegal key: #{key}"

  @check_update: (update) ->
    for key of update
      if key[0] != '$'
        console.log "#{@collection._name}: illegal update: #{key}"
        throw "#{@collection._name}: illegal update: #{key}"
      @check_fields_legal update[key]

  @insert: (obj) ->
    @check_fields_exist obj
    @check_fields_legal obj
    @collection.insert obj

  @get: (_id) ->
    @collection.findOne _id: _id

  @find: (selector, options) ->
    if selector?
      console.log(@collection, selector) if @verbose
      @check_fields_legal selector
      return @collection.find selector, options
    @collection.find()

  @findOne: (selector, options) ->
    if selector?
      console.log(@collection, selector) if @verbose
      @check_fields_legal selector
      return @collection.findOne selector, options
    @collection.findOne()

  @update: (selector, update) ->
    if not selector?
      throw 'update called with no selector!'
    @check_fields_legal selector
    @check_update update
    console.log(@collection, selector, update) if @verbose
    @collection.update selector, update, multi: true

  @remove: (selector) ->
    if not selector?
      throw 'remove called with no selector!'
    @check_fields_legal selector
    console.log(@collection, selector) if @verbose
    @collection.remove selector

  @cleanup: (clause) ->
    if Common.keep_history
      @update clause, $set: $active: false
    else
      @remove clause
