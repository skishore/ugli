@using = (obj, block) -> block.call obj


class @Collection
  constructor: (@name, @fields, unique_index) ->
    @collection = new Meteor.Collection @name
    if unique_index and Meteor.isServer
      @collection._ensureIndex unique_index, unique: true

  check_fields_exist: (schema) =>
    for key in @fields
      if key not of schema
        console.log 'Missing key: ' + key
        throw 'Missing key: ' + key

  check_fields_legal: (schema) =>
    for key of schema
      if key not in @fields and key != '_id'
        console.log 'Illegal key: ' + key
        throw 'Illegal key: ' + key

  check_update: (update) =>
    for key of update
      if key[0] != '$'
        console.log 'Illegal update: ' + key
        throw 'Illegal update: ' + key
      @check_fields_legal update[key]

  insert: (obj) =>
    @check_fields_exist obj
    @check_fields_legal obj
    @collection.insert obj

  find: (selector) =>
    if selector
      @check_fields_legal selector
      return @collection.find selector
    @collection.find()

  findOne: (selector) =>
    if selector
      @check_fields_legal selector
      return @collection.findOne selector
    @collection.findOne()

  update: (selector, update) =>
    if not selector
      throw 'Remove called with no selector!'
    @check_fields_legal selector
    @check_update update
    @collection.update selector, update

  remove: (selector) =>
    if not selector
      throw 'Remove called with no selector!'
    @check_fields_legal selector
    @collection.remove selector
