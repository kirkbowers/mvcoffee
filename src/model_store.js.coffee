class MVCoffee.ModelStore
  MIN_DATA_FORMAT_VERSION: "1.0.0"

  constructor: (models = {}) ->
    # modelDefs holds a hash that maps a string name of a model to the constructor
    # object of that model
    @modelDefs = {}
    
    # store holds a hash that maps a string name of a model to a hash of all records
    # of that model that have been fetched keyed on their "id" property
    @store = {}
    
    for name, classdef of models
      @addModel name, classdef
    
  addModel: (name, classdef) ->
    @modelDefs[name] = classdef
    
    # Stash the name of this model and this model store back on the prototype of the
    # class for this model.  Both will come in handy for doing queries.
    classdef.prototype.modelName ||= name
    classdef.prototype.modelNamePlural ||= MVCoffee.Pluralizer.pluralize(name)
    classdef.prototype.modelStore = this
    
    # Initialize the store for this model
    @store[name] = {}
    
  # load takes an object, most likely one instantiated from json, and loads the whole
  # shebang into the datastore.  It replaces any instances that have a matching id
  # to something in the input data.
  # The return value is almost the same hash as the one passed in as "data", but with
  # each recognized model replaced with an mvcoffee model object instead of hashes 
  # (or each array of a recognized model replaced with an array of mvcoffee models).
  # Any property that is not recognized as a registered model is passed through.
  # If the second parameter is supplied, the new models are merged into the supplied
  # object.
  load: (object) ->
    if not object.version? or object.version < @MIN_DATA_FORMAT_VERSION
      throw "MVCoffee.DataStore requires minimum data format " + @MIN_DATA_FORMAT_VERSION

    for modelName, commands of object.models
      if @modelDefs[modelName]?
        # This is a model we know about
        if commands.replace_on?
          if Array.isArray commands.replace_on
            toBeRemoved = []
            for foreignKeys in commands.replace_on
              toBeRemoved = toBeRemoved.concat @where(modelName, foreignKeys)

          else
            toBeRemoved = @where(modelName, commands.replace_on)

          for record in toBeRemoved
            delete @store[modelName][record.id]

        if commands.data?
          if Array.isArray commands.data
            for modelObj in commands.data
              model = new @modelDefs[modelName](modelObj)
              @store[modelName][model.id] = model
          else
            model = new @modelDefs[modelName](commands.data)
            @store[modelName][model.id] = model
              
        if commands.delete?
          # If this is an array, we need to load each in turn
          if Array.isArray commands.delete
            for modelId in commands.delete
              delete @store[modelName][modelId]
          else
            delete @store[modelName][commands.delete]

      
  # find finds the one record that is of the model supplied and has the id supplied
  find: (model, id) ->
    @store[model]?[id]
    
  # findBy finds the first record of a model that match all conditions given
  # conditions is a hash of column names and values to match
  findBy: (model, conditions) ->
    records = @store[model] ? {}
    result = null
    for id, record of records
      match = true
      for prop, value of conditions
        if record[prop] isnt value
          match = false
      result ||= record if match 
    result  
      
  # where finds all the records of a model that match all conditions given
  # conditions is a hash of column names and values to match
  where: (model, conditions) ->
    records = @store[model]
    result = []
    for id, record of records
      match = true
      for prop, value of conditions
        if record[prop] isnt value
          match = false
      result.push(record) if match
    result
    
  # Pulls all records for a model that are currently in the cache
  all: (model) ->
    records = @store[model]
    result = []
    for id, record of records
      result.push(record)
    result

  