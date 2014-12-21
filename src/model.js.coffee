
class MVCoffee.Model
  constructor: (obj)->
    if obj?
      @populate(obj)

  # This must be overridden in subclasses to give the name of the model in rails land
  # Leave it as null if the form is built with form_tag instead of a form_for built on
  # a model
  modelName: null
  
  # This must be overridden in subclasses to provide an array of fields and their 
  # properties
  fields: []
  
  # This is a pseudo-private property that lists all has many associations
  _associations_has_many: []
  
  errors: []
  valid: true

  #----------------------------------------------------------------------------
  # Static query method definitions
  
  @order: (array, order, opts = {}) ->
    result = array
    [prop, desc] = order.split(/\s+/)
    value = 1
    if desc? and desc is "desc"
      value = -1
    ignoreCase = false
    if opts.ignoreCase
      ignoreCase = true
    result.sort (a, b) ->
      a = a[prop]
      b = b[prop]
      if ignoreCase
        if a.toLowerCase
          a = a.toLowerCase()
        if b.toLowerCase
          b = b.toLowerCase()
      if a > b
        value
      else if a < b
        -value
      else
        0
    result
  
  @all: (options = {})->
    result = @prototype.modelStore.all(@prototype.modelName)
    if options.order
      result = @sort(result, options.order)
    result
    
  @find: (id) ->
    @prototype.modelStore.find(@prototype.modelName, id)

  # findBy finds the first record of this model that match all conditions given.
  # conditions is a hash of column names and values to match
  @findBy: (conditions) ->
    @prototype.modelStore.findBy(@prototype.modelName, conditions)
      
  # where finds all the records of this model that match all conditions given.
  # conditions is a hash of column names and values to match
  @where: (conditions) ->
    @prototype.modelStore.where(@prototype.modelName, conditions)
    

  #----------------------------------------------------------------------------
  # Instance methods for CRUD-type stuff
  
  delete: ->
    # Recursively delete all dependent children
    for assoc in @_associations_has_many
      children = @[assoc]()
      for child in children
        child.delete()
  
    @modelStore.delete(@modelName, @id)
  
  # Just a rails like alias
  destroy: ->
    @delete()
  
  #----------------------------------------------------------------------------
  # Macro method definitions

  # This has no real use as a macro method, but it is reusable by other macro methods
  @findFieldIndex: (field) ->
    # This is an ugly way to find an arbitrary match in an array
    # ES6 has a findIndex method that takes a function as a parameter, but I have to
    # expect most browsers are running ES5
    fields = @prototype.fields
    index = -1
    for i in [0...fields.length]
      index = i if fields[i].name is field
    index  

  # This replaces the v0.1 way of declaring validations on a model.  Actually, it 
  # doesn't totally replace it, it depends on that old way under the hood, but it
  # provides a much cleaner syntax.
  @validates: (field, test) ->
    # This is the trick to doing a "macro method" in javascript
    # We have to operate on the prototype of this.
    # We also have to guard against working on the parent class prototype inadvertantly.
    # So we need to check if we have our own property fields first and create it if we
    # don't
    @prototype.fields = [] unless @prototype.hasOwnProperty("fields")
    fields = @prototype.fields

    # If there is already an object on the fields property that has this field name,
    # we want to attach this validation to that field rather than add to the fields
    # array.  See if we find it first.
    index = @findFieldIndex(field)
      
    if index < 0
      # We didn't find a match for this field name, so we can just "safely" push a new
      # object onto the fields array.  I say "safely" because there is no guarentee
      # that a client didn't do something stupid like make fields a non-array on the
      # model's prototype, but we don't mind an error being thrown if that happened.
      #
      # I put the test in an array because it makes adding more validations later
      # easier.  The validates as a single object notation is just a convenience for
      # v0.1 style declarations.
      fields.push
        name: field,
        validates: [test]
    else
      field = fields[index]
      if field.validates?
        # This field may exist already with no validations, most likely for a type
        # convertion if it does.  But if we do have a validates property, we want to 
        # add to it instead of just setting it.
        # It may be a single object, for the v0.1 convenience style mentioned above, 
        # or it may already be an array.
        if Array.isArray field.validates
          field.validates.push test
        else
          field.validates = [field.validates, test]
      else
        field.validates = [test]

  # This is types as a verb, not as in presses keys on a typewriter, but as in sets
  # the type of.  The typical use would be:
  #    it.types "some_field", "boolean"
  @types: (field, type) ->
    @prototype.fields = [] unless @prototype.hasOwnProperty("fields")
    fields = @prototype.fields

    index = @findFieldIndex(field)
      
    if index < 0
      fields.push
        name: field,
        type: type
    else
      fields[index].type = type    
      
  @displays: (field, display) ->
    @prototype.fields = [] unless @prototype.hasOwnProperty("fields")
    fields = @prototype.fields

    index = @findFieldIndex(field)
      
    if index < 0
      fields.push
        name: field,
        display: display
    else
      fields[index].display = display   
  

  # I really debated on the name of this.  I think camel case is the norm in js land
  # but snake case is the norm in ruby for method names.  This method is modeled after
  # the has_many method in rails.  The best I could think to do was provide both, one
  # as sort of an alias to the other.
  @hasMany: (name, options = {}) ->
    methodName = options.as || MVCoffee.Pluralizer.pluralize(name)
    
    # Place this on the array of has many associations
    @prototype._associations_has_many = [] unless @prototype.hasOwnProperty("_associations_has_many")
    @prototype._associations_has_many.push methodName
    
    # Stash this reference, because "this" is about to change
    self = this
    @prototype[methodName] = ->
      modelStore = self.prototype.modelStore
      foreignKey = options.foreignKey || options.foreign_key || "#{self.prototype.modelName}_id"
      
      # @ now refers to the object "this", not the static class "this"
      result = []
      if modelStore?
        constraints = {}
        constraints[foreignKey] = @id
        result = modelStore.where(name, constraints)
        
      if options.order
        result = self.order(result, options.order)
      result
    
  @has_many: @hasMany
  
  @belongsTo: (name, options = {}) ->
    methodName = options.as || name
    foreignKey = options.foreignKey || options.foreign_key || "#{name}_id"
    # Stash this reference, because "this" is about to change
    self = this
    @prototype[methodName] = ->
      modelStore = self.prototype.modelStore
      # @ now refers to the object "this", not the static class "this"
      result = null
      if modelStore?
        result = modelStore.find(name, @[foreignKey])
        
      # TODO!!!
      # Handle other options, maybe there are none
      result
    
  @belongs_to: @belongsTo

  #----------------------------------------------------------------------------
  # Regular method definitions
  
  isValid: ->
    @valid
  
  populate: (obj) ->
    if obj?
      # If we are passed an object, copy it, merging its properties into ours
      # (overwriting ours if a property already exists)
      for field, value of obj
        # Probably unnecessary safeguard, but js objects can be wonky.
        if obj.hasOwnProperty(field)
          # Only do the recursive loading of models into the model store on complex
          # child data if the model store "knows about" a model with this name
          # otherwise it's just arbitrary data (like an array of numbers, not an array
          # of model objects)
          if (value instanceof Object or value instanceof Array) and @modelStore.knowsAbout field
            
            @modelStore.load_model_data(field, value)
          else
            this[field] = value
    else
      # Otherwise, if this method was called with no argument, populate from the
      # form on the page using jquery
      for field in @fields
        if @modelName?
          selector = "##{@modelName}_#{field.name}"
        else
          selector = "##{field.name}"
        if field.type? and field.type == 'boolean'
          this[field.name] = jQuery(selector).is(':checked')
        else
          this[field.name] = jQuery(selector).val()
        
    @validate()
    
    
  validate: ->
    @valid  = true
    @errors = []
    for field in @fields
      if field.validates?
        # First see if the validation is an object or an array.  This is a notational
        # convenience, if there is only one validation, there is no need to force the
        # client to supply an array
        validations = field.validates
        unless Array.isArray(validations)
          validations = [ validations ]
        for validation in validations
          if validation.test is 'acceptance'
            value = validation.accept
            unless value?
              value = '1'
            @__performValidation(field, validation, null,
              "must be accepted", 
              (val) ->
                val is value
            )
          else if validation.test is 'confirmation'
            confirm = this["#{field.name}_confirmation"]
            @__performValidation(field, validation, null,
              "doesn't match confirmation", 
              (val) ->
                val? and val isnt "" and confirm? and val is confirm
            )
          else if validation.test is 'email'
            @__performValidation(field, validation, null,
              "must be a valid email address", 
              (val) ->
                val? and val.match(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/)
            )
          else if validation.test is 'exclusion'
            matches = validation["in"] || []
            @__performValidation(field, validation, null,
              "is reserved", 
              (val) ->
                val? and not (val in matches)
            )
          else if validation.test is 'format'
            matches = validation["with"] || /.*/
            @__performValidation(field, validation, null,
              "is invalid", 
              (val) ->
                val? and matches.test(val)
            )
          else if validation.test is 'inclusion'
            matches = validation["in"] || []
            @__performValidation(field, validation, null,
              "is not included in the list", 
              (val) ->
                val? and val in matches
            )
          else if validation.test is 'length'
            tokenizer = (val) ->
              val.split("")
              
            if validation.tokenizer?
              tokenizer = validation.tokenizer
          
            if validation.minimum?
              if typeof validation.minimum == "number"
                subval = null
                value = validation.minimum
              else
                subval = validation.minimum
                value = subval.value
              @__performValidation(field, validation, subval,
                "is too short (minimum is #{value} characters)",
                (val) -> 
                  val? and tokenizer(val).length >= value
              )
            if validation.maximum?
              if typeof validation.maximum == "number"
                subval = null
                value = validation.maximum
              else
                subval = validation.maximum
                value = subval.value
              @__performValidation(field, validation, subval,
                "is too long (maximum is #{value} characters)",
                (val) -> 
                  # If the value is null, it is definitely below the maximum in length
                  not val? or tokenizer(val).length <= value
              )
            # Using the square bracket notation here since "is" is a reserved word
            # in coffeescript
            if validation["is"]?
              if typeof validation["is"] == "number"
                subval = null
                value = validation["is"]
              else
                subval = validation["is"]
                value = subval.value
              @__performValidation(field, validation, subval,
                "is the wrong length (must be #{value} characters)",
                (val) -> 
                  val? and tokenizer(val).length is value
              )
              
          else if validation.test is 'numericality'
            # First make sure we even have a valid number to work with.
            # If it isn't valid, we can skip any sub-validations
            if validation.only_integer? and validation.only_integer
              isNumber = @__performValidation(field, validation, null,
                "must be an integer",
                (val) -> 
                  /^[-+]?\d+$/.test(val)
              )
            else
              isNumber = @__performValidation(field, validation, null,
                "must be a number",
                (val) ->
                  number = parseFloat(val)
                  # This is a cheap regexp test for the most common number formats.
                  # I think this covers everything legal in rails land while disallowing
                  # things that rails doesn't like leading or trailing whitespace or
                  # non numbers after the number.  javascripts parseFloat does ignore
                  # such whitespace and ignores any stuff from the first non-number on,
                  # so a simple check against NaN isn't strong enough.
                  /^[-+]?\d*\.?\d*(e\d+)?$/.test(val) and number is number
              )
            
            if isNumber
              if validation.greater_than?
                if typeof validation.greater_than == "number"
                  value = validation.greater_than
                  subval = null
                else
                  subval = validation.greater_than
                  value = subval.value
                @__performValidation(field, validation, subval,
                  "must be greater than #{value}",
                  (val) -> 
                    parseFloat(val) > value
                )
              if validation.greater_than_or_equal_to?
                if typeof validation.greater_than_or_equal_to == "number"
                  subval = null
                  value = validation.greater_than_or_equal_to
                else
                  subval = validation.greater_than_or_equal_to
                  value = subval.value
                @__performValidation(field, validation, subval,
                  "must be greater than or equal to #{value}",
                  (val) -> 
                    parseFloat(val) >= value
                )
              if validation.equal_to?
                if typeof validation.equal_to == "number"
                  subval = null
                  value = validation.equal_to
                else
                  subval = validation.equal_to
                  value = subval.value
                @__performValidation(field, validation, subval,
                  "must be equal to #{value}",
                  (val) -> 
                    parseFloat(val) == value
                )
              if validation.less_than?
                if typeof validation.less_than == "number"
                  value = validation.less_than
                  subval = null
                else
                  subval = validation.less_than
                  value = subval.value
                @__performValidation(field, validation, subval,
                  "must be less than #{value}",
                  (val) -> 
                    parseFloat(val) < value
                )
              if validation.less_than_or_equal_to?
                if typeof validation.less_than_or_equal_to == "number"
                  subval = null
                  value = validation.less_than_or_equal_to
                else
                  subval = validation.less_than_or_equal_to
                  value = subval.value
                @__performValidation(field, validation, subval,
                  "must be less than or equal to #{value}",
                  (val) -> 
                    parseFloat(val) <= value
                )
              if validation.odd?
                if typeof validation.odd == "boolean"
                  subval = null
                  value = validation.odd
                else
                  subval = validation.odd
                  value = true
                if value
                  @__performValidation(field, validation, subval,
                    "must be odd",
                    (val) -> 
                      Math.abs(parseFloat(val)) % 2 == 1
                  )
              if validation.even?
                if typeof validation.even == "boolean"
                  subval = null
                  value = validation.even
                else
                  subval = validation.even
                  value = true
                if value
                  @__performValidation(field, validation, subval,
                    "must be even",
                    (val) -> 
                      parseFloat(val) % 2 == 0
                  )
                
                
          else if validation.test is 'presence'
            @__performValidation(field, validation, null, "can't be empty", (val) ->
              val? and /\S+/.test(val)
            )
          else if validation.test is 'absence'
            @__performValidation(field, validation, null, "must be blank", (val) ->
              not (val? and /\S+/.test(val))
            )

          else
            # If the test name is not one we recognize, then it must be the name of 
            # a method supplied by the client.  Run it
            unless typeof this[validation.test] is 'function'
              throw "custom validation is not a function"
            @__performValidation(field, validation, null, "is invalid", 
              this[validation.test])
              
    # All done, return whether or not is valid
    @valid
    
  

  # This naming of this is a touch clumsy.  I'm using the double underscore prefix to 
  # make this sort of kind of private.  There's almost no risk that the name 
  # "performValidation" would clash with model's field name, but just in case, I 
  # "hide" this method with __
  #
  # It takes five params:
  #  field: The field to be validated
  #  validation: The actual validation object.  It may have extra flags that we need
  #    to check, like only_if or allow_null, or it may have a custom message.
  #  subval: An optional subvalidation object.  This is used by tests like numericality
  #    greater_than to have finer grain control over the message, unless and only_if.
  #    If left blank, it is ignored.
  #  message: the standard message if this comparison fails.  It should be in the 
  #    form of the end of the sentence that will follow the field's display name, a la
  #    "must not be blank"
  #  comparison: is a function that takes one argument (the value being tested) and
  #    returns a boolean.  For simple comparisons like presence, it can be a simple
  #    function like:
  #       (val) ->
  #         val? and /\S+/.test(val)
  #    For a comparison that has some value supplied by the validation to compare 
  #    against, such as greater_than, the value must be curried/closured, a la:
  #       (val) ->
  #         val > validation.value
  #  
  # The return value will always be a boolean.  If the test is skipped because of some
  # option like allow_null, true will be returned.  Otherwise, false will be returned
  # if the comparison yields a falsy answer.
  __performValidation: (field, validation, subval, message, comparison) ->
    # First check if there is an only_if function supplied.  If so, it must be in the
    # form of a string that matches the name of the method.  It can be accessed using
    # javascript's square bracket property notation, then executed with parens.
    # BTW, it is named "only_if" instead of the rails-like "if" just because "if" is
    # a reserved word in javascript and may cause problems.  I could probably work 
    # around it by always using the square bracket notation, but I don't trust it.
    # This works well enough, and is readable enough...
    if validation.only_if? and not this[validation.only_if]()
      # We bail out if the only_if function returned false, ie bail if not only_if
      return true
      
    # Similarly, do the same thing with unless
    if validation.unless? and this[validation.unless]()
      # Backwards of only_if, this time we bail on true
      return true
      
    if subval?
      if subval.only_if? and not this[subval.only_if]()
        # We bail out if the only_if function returned false, ie bail if not only_if
        return true
      
      # Similarly, do the same thing with unless
      if subval.unless? and this[subval.unless]()
        # Backwards of only_if, this time we bail on true
        return true
    
    # Since we've gotten through those tests, we can fetch the actual data stored
    # in the field so we can do comparisons with it
    data = this[field.name]
    
    # Now we check if the test allows null.  If so, and it is null, we can bail
    if validation.allow_null? and validation.allow_null and not data?
      return true
      
    # Check the less restrictive all_blank now.
    if (
      validation.allow_blank? and 
      validation.allow_blank and 
      (not data? or not /\S+/.test(data))
    )
      return true
      
    # Okay, we've gotten through all the optional validation guards, we can go ahead
    # and perform the comparison
    unless comparison(data)
      @addError(field, validation, subval, message)
      return false
      
    # If we've gotten this far, it's valid, so return true
    true


  addError: (field, validation, subval, message) =>
    @valid = false
    name = field.display
    unless name?
      name = field.name
      if name.length > 0
        # capitalize the first letter
        name = name[0].toUpperCase() + name.slice(1);
        name = name.split("_").join(" ");
    # There's three layers of trumping on the message.  If there is a subvalidation,
    # and it has a message, that wins.  Next is the message on the validation, then
    # the fallback is the default message passed as the fourth param.
    if subval?.message?
      @errors.push("#{name} #{subval.message}")      
    else if validation?.message?
      @errors.push("#{name} #{validation.message}")
    else
      @errors.push("#{name} #{message}")
