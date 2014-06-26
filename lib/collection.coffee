# A class that wraps a collection with some basic schema checking.
# To use this class:
#   1. Create a subclass for the collection you want to wrap.
#   2. Call the set_schema method with a schema object:
#       collection OR name: a collection to wrap, or the name of a new one
#       durable (optional): defaults to true, backed by minimongo if false
#       fields: a list of column-name strings
#       indices (optional): a list of index specs:
#         columns: a Mongo index column spec
#         options (optional): a list of options for the index

class @Collection
  @set_schema: (schema) ->
    if schema.collection?
      @collection = schema.collection
    else
      check schema.name, String
      @durable = if 'durable' of schema then schema.durable else true
      check @durable, Boolean
      options = if Meteor.isClient or @durable then {} else connection: null
      @collection = new Meteor.Collection schema.name, options
    check schema.fields, [String]
    @fields = schema.fields
    if Meteor.isServer and @durable
      for index in (if schema.indices? then schema.indices else [])
        if not 'columns' of index
          throw Error "Illegal index: #{index}"
        if (key for key of index).length > 1 and not 'options' of index
          throw Error "Illegal index: #{index}"
        @collection._ensureIndex index.columns, index.options

  @_check_fields_exist: (schema) ->
    for key in @fields
      if key not of schema
        throw new UGLIModelError "#{@collection._name}: missing key: #{key}"

  @_check_fields_legal: (document) ->
    for key of document
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
    do @collection.find

  @findOne: (selector, options) ->
    if selector?
      @_check_fields_legal selector
      return @collection.findOne selector, options
    do @collection.findOne

  @insert: (document) ->
    @_check_fields_exist document
    @_check_fields_legal document
    @collection.insert document

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
