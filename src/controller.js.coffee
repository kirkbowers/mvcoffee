class MVCoffee.Controller
  constructor: (@id, @manager) ->
    @selector = "#" + id
    @timerId = null
    @isActive = false
  
  start: ->    
    # isActive keeps track of whether we actually have the focus on this controller or
    # not.  It is used to protect against running refresh prematurely.  The window
    # does get the focus when a full page load is performed, which if you are running
    # rails with turbolinks is when the first page of your app is first visited.  This
    # kind of onfocus should not trigger a refresh (since we just got here and are 
    # getting the page fresh from the server), so set the isActive flag before setting
    # the window.onfocus to fire the refresh method.
    @isActive = true
    
    # First thing we want to do is get the authenticity token that rails supplies,
    # just in case this is rails on the backend
    @authenticity_token = jQuery("meta[name='csrf-token']").attr("content");
            
        
    
    @onStart()
        
    if @refresh?
      @startTimer()
       
  resume: ->
    if @refresh? and not @isActive
      @isActive = true
      @refresh()
      @startTimer()      
  
  pause: ->
    if @refresh?
      @isActive = false
      @stopTimer()
      
  stop: ->
    @isActive = false
    @onStop()
    
    if @refresh?
      @stopTimer()
      
  turbolinkForms: (validations = {}) ->
    if Turbolinks?
      self = this
      $("form").each (index, element) =>
        if validations[element.id]?
          $(element).submit ->
            model = validations[element.id]
            model.populate()
            method = "#{element.id}_errors"
            if self[method]?
              self[method](model.errors)
            else
              console.log("!!! method not implemented !!!")
              
            if model.isValid()
              self.turbolinksPost element
            false
        else
          $element = $(element)
          if element.method is "get" or element.method is "GET"
            $(element).submit ->
              Turbolinks.visit element.action
              false
          else
            $(element).submit =>
              self.turbolinksPost(element)
                    
  turbolinksPost: (element) ->
    # console.log "Submiting #{element.id} over turbolinks"
    $.post(element.action,
      $(element).serialize(),
      (data) =>
        # console.log "Form submit returned: " + JSON.stringify(data)
        if data.errors?
          method = "#{element.id}_errors"
          # console.log "Calling method on controller: " + method
          if @[method]?
            @[method](data.errors)
          #else
          # TODO!!!
          # Do something to alert the user of the error
        else
          if data.redirect?
            @manager.flash = data.flash
            Turbolinks.visit(data.redirect)
          else
            method = element.id
            if @[method]?
              @[method](data)
            # else
            # TODO!!! Do something?   
      ,
      'json')
    false
  
  
  # One minute, 60 millis
  refreshInterval: 60000
  
  # Overrideable template methods
  refresh: null
  onStart: ->
    # no-op unless overridden
    
  onStop: ->
    # no-op unless overridden
  
  toString: ->
    @id
    
  startTimer: ->
    if @timerId?
      @stopTimer()
    if @refreshInterval? and @refreshInterval > 0
      self = this
      @timerId = setInterval(
        -> self.refresh.call(self) 
        @refreshInterval
      )
    
  stopTimer: ->
    if @timerId?
      clearInterval(@timerId)
    @timerId = null
