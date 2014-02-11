# polyfill Array.isArray, just in case

if !Array.isArray
  Array.isArray = (arg) ->
    Object.prototype.toString.call(arg) is '[object Array]'


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
  
  errors: []
  valid: true
  
  isValid: ->
    @valid
  
  populate: (obj) ->
    if obj?
      # If we are passed an object, copy it, merging its properties into ours
      # (overwriting ours if a property already exists)
      for field of obj
        # Probably unnecessary safeguard, but js objects can be wonky.
        if obj.hasOwnProperty(field)
          this[field] = obj[field]
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
