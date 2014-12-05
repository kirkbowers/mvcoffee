class MVCoffee.Controller
  constructor: (@id, @runtime) ->
    @selector = "#" + id
    @timerId = null
    @isActive = false
    
    # This is a weird javascript-ism
    # We can set up pass through methods, but we can't do it on the prototype.
    # We have to do it only after the object has been instantiated and we have a live
    # reference to the object we are delegating to.
    
    @processServerData = @runtime.processServerData
    @getFlash = @runtime.getFlash
    @setFlash = @runtime.setFlash
    @getSession = @runtime.getSession
    @setSession = @runtime.setSession
    @getErrors = @runtime.getErrors
    
    @timerCount = 0
  
  #==================================================================================
  #
  # Life cycle methods.
  # 
  # These should never be overridden.  
  # Each provides an entry point called on<Event> that should be overridden if you need
  # to do something when this event is fired.  Normally, onStart is the only such 
  # entry point you should ever need.  That, and refresh.  onResume is there for 
  # completeness sake in case you ever need to do something unique on a resume that you
  # wouldn't have to do on a timer-fired refresh.  I can't think of what that'd be, but
  # it's there for those things I can't anticipate...
  # 
  # A warning:  onPause may not always fire.  Safari in iOS does not detect the browser
  # losing focus.  Also, onStop may not fire in some browsers when the window is closed.
  #
 
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
    @onResume()
  
    console.log "resume called on controller " + @toString()
    console.log "isActive = " + @isActive
    if @refresh? and not @isActive
      @isActive = true
      @refresh()
      @startTimer()      
  
  pause: ->
    @onPause()
    
    console.log "pause called on controller " + @toString()
    if @refresh?
      @isActive = false
      @stopTimer()
      
  stop: ->
    @isActive = false
    @onStop()
    
    if @refresh?
      @stopTimer()
      
      
  #==================================================================================
  #
  # turbolinkForms
  # 
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
            # The "model" customization performs validation with the supplied
            # model instance.  NOTE:  it must be an instance, not a model 
            # constructor function.
            # If validation fails, the method that matches the form's id with
            # _errors appended will be called with the errors array.
            model = customization.model
            if model?
              model.populate()
              method = "#{element.id}_errors"
              if self[method]?
                self[method](model.errors)
              else
                console.log("!!! method #{method} not implemented !!!")
              
              doPost = model.isValid()

            # The "confirm" customization pops up a confirm dialog
            confirm = customization.confirm
            if doPost and confirm?
              if confirm instanceof Function
                doPost = confirm()
              else
                doPost = window.confirm(confirm)
                        
            if doPost
              self.turbolinksSubmit element
              
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
              self.turbolinksSubmit(element)
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
                @runtime.processServerData(data, element.id)
              dataType: "json"
            )
          false
        )
  
           
  #==================================================================================
  #
  # Convenience methods to fetch data over ajax
  #

  # This is get in the sense of getting json, not issuing a browser get to visit another
  # page.
  # It sends back the entire session hash with the expectation that any caching time
  # stamps are kept there.
  get: (url, callback_message = "render") ->
    $.get(url,
      @runtime.session,
      (data) =>
        @runtime.processServerData data, callback_message
      ,
      'json')
                  
  post: (url, params = {}, callback_message = "render") ->
    $.extend params,
        authenticity_token: @authenticity_token
        @session
    $.post(url,
      params,
      (data) =>
        @runtime.processServerData data, callback_message
      ,
      'json')
                  
  # This has a different naming convention than the "get" above, as it isn't just a
  # generic post to the server.  It is "unobtrusive" posting of a form turbolinks style.
  # The form should be provided as the element param.  This is a javascript reference to
  # the page element, not a jQuery object.
  # You usually won't have to call this manually.  It is called for you if you 
  # turbolinkForms the page.  However, you may need to call it if you do any 
  # 
  turbolinksSubmit: (submitee) ->
    element = submitee
    if submitee instanceof jQuery
      element = submitee.get(0)
    console.log "Submiting #{element.id} over turbolinks"
    jQuery.post(element.action,
      $(element).serialize(),
      (data) =>
        @processServerData(data, element.id)
      ,
      'json')
    false
  
  
  
  #==================================================================================
  #
  # Refresh policy and callback
  #

  # One minute, 60 millis
  refreshInterval: 60000
  
  # Overrideable template methods
  refresh: null


  #==================================================================================
  #
  # Life cycle entry points
  # 
  
  onStart: ->
    # no-op unless overridden
    
  onPause: ->
    # no-op unless overridden
    
  onResume: ->
    # no-op unless overridden
    
  onStop: ->
    # no-op unless overridden
    
  render: ->
    # no-op unless overridden
  
  toString: ->
    @id
    
    
  #==================================================================================
  #
  # Handling the timer.  Do not override or call manually.  This are fired automatically
  # by the life cycle methods.
  # 
  
  startTimer: ->
    if @timerId?
      @stopTimer()
    if @refreshInterval? and @refreshInterval > 0
      self = this
      @timerCount += 1
      console.log "Starting timer with count of #{@timerCount}"
      @timerId = setInterval(
        -> 
          console.log "Firing timer with count of #{self.timerCount}"
          self.refresh.call(self) 
        @refreshInterval
      )
      console.log "Started timerId #{@timerId}"
    
  stopTimer: ->
    console.log("Stopping timer")
    if @timerId?
      console.log("clearing the interval with timerId #{@timerId}")
      clearInterval(@timerId)
    @timerId = null
