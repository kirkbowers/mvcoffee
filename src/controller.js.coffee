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
    token = jQuery("meta[name='csrf-token']")
    if token?.length
      @authenticity_token = token.attr("content");
            
        
    
    @onStart()
    @render()
        
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
      
  # This method must be explicitly called inside of onStart in subclasses that want
  # to handle form submission through turbolinks.  By default, form submission causes
  # a full refresh of the page, even with turbolinks enabled.  That may not be what we
  # want if we have data cached client side.  Calling this method causes form submission
  # to automagically happen over ajax, just as if turbolinks were handling it.
  turbolinkForms: (customizations = {}) ->
    # If this is a Rails 4 project with turbolinks enabled
    if Turbolinks?
      self = this
      # We want to add our own "unobtrusive" javascript on every form on the page
      jQuery("form").each (index, element) =>
        # The allowed customizations are "confirm" and "model"
        if customizations[element.id]?
          customization = customizations[element.id]
          $(element).submit ->
            doPost = true
            # The "confirm" customization pops up a confirm dialog
            confirm = customization.confirm
            if confirm?
              doPost = window.confirm(confirm)
            
            # The "model" customization performs validation with the supplied
            # model instance.  NOTE:  it must be an instance, not a model 
            # constructor function.
            # If validation fails, the method that matches the form's id with
            # _errors appended will be called with the errors array.
            model = customization.model
            if doPost and model?
              model.populate()
              method = "#{element.id}_errors"
              if self[method]?
                self[method](model.errors)
              else
                console.log("!!! method #{method} not implemented !!!")
              
              doPost = model.isValid()
            
            if doPost
              self.turbolinksPost element
              
            # Always return false to supress a true post 
            false
        else
          # No customizations being done
          $element = $(element)
          
          # Just follow the link if it is a "get"
          if element.method is "get" or element.method is "GET"
            $(element).submit ->
              Turbolinks.visit element.action
              false
          else
            # Or just submit the form if it is a "post"
            $(element).submit =>
              self.turbolinksPost(element)
              false
      
      # Do the same thing for a links that have a data-method of "delete"
      jQuery("a[data-method='delete']").each (index, element) =>
        # console.log("Found a delete link! url=" + element.href) 
        jQuery(element).click( =>
          doPost = true
          # The "confirm" customization pops up a confirm dialog
          confirm = jQuery(element).data("confirm")
          if confirm?
            doPost = window.confirm(confirm)

          if doPost
            jQuery.ajax(
              url: element.href,
              type: 'DELETE',
              success: (data) =>
                @processServerData(data, element)
              dataType: "json"
            )
          false
        )
                    
  turbolinksPost: (element) ->
    # console.log "Submiting #{element.id} over turbolinks"
    jQuery.post(element.action,
      $(element).serialize(),
      (data) =>
        @processServerData(data, element)
      ,
      'json')
    false
  
  processServerData: (data, element) ->
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
      @manager.loadData(data)
      # console.log("In controller post: " + JSON.stringify(data))
      if data.redirect?
        # @manager.flash = data.flash
        Turbolinks.visit(data.redirect)
      else
        method = element.id
        if @[method]?
          @[method](data)
        # else
        # TODO!!! Do something?   
  
  # One minute, 60 millis
  refreshInterval: 60000
  
  # Overrideable template methods
  refresh: null
  onStart: ->
    # no-op unless overridden
    
  onStop: ->
    # no-op unless overridden
    
  render: ->
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
