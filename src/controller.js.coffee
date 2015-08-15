class MVCoffee.Controller
  constructor: (@id, @_runtime) ->
    @selector = "#" + @id
    @timerId = null
    @isActive = false
    
    # This is a weird javascript-ism
    # We can set up pass through methods, but we can't do it on the prototype.
    # We have to do it only after the object has been instantiated and we have a live
    # reference to the object we are delegating to.
    
    # Yes, this is a lot of pass through methods!  The runtime provides most of the
    # functionality, but ideally we don't call the runtime directly inside of 
    # concrete controller subclasses.  That's why the reference to the runtime has a
    # quasi-private name, with a leading underscore.  If you call it directly, it will
    # look wonky in your code, so that should warn you that you'd better have a good
    # reason and know what you are doing.
    
    @processServerData = @_runtime.processServerData
    @getFlash = @_runtime.getFlash
    @setFlash = @_runtime.setFlash
    @getSession = @_runtime.getSession
    @setSession = @_runtime.setSession
    @getErrors = @_runtime.getErrors
    
    @dontClientize = @_runtime.dontClientize
    
    # This is named "re" to remind you that you only ever call this if you've redrawn
    # some section of the screen in your render method.  Only call this on the scope of
    # the area you've redrawn
    @reclientize = @_runtime.clientize
    
    @visit = @_runtime.visit
    @fetch = @_runtime.fetch
    @post = @_runtime.post
    @delete = @_runtime.delete
    @submit = @_runtime.submit
    
    @timerCount = 0

  #==================================================================================
  #
  # Specialized pass through methods
  #
  # Most things that we want to delegate to the runtime we can just call the runtime
  # method as is.  Sometimes we need to pass a reference back to the calling
  # controller.  Ideally, clients of this framework don't need to know when, just call
  # any method in a consistent manner and let the pass through do the right thing.
  #

  addClientizeCustomization: (customization) ->
    customization.controller = this
    @_runtime.addClientizeCustomization customization  
  

  
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
    
    @onStart()
    # I don't want render to happen automatically here anymore.  I want the runtime
    # to fire it after it's done the clientize, just in case render redraws something
    # and needs to reclientize just that scope.
    # @render()
        
    if @refresh?
      @startTimer()
       
  resume: ->
    @onResume()
  
    if @refresh? and not @isActive
      @isActive = true
      @refresh()
      @startTimer()      
  
  pause: ->
    @onPause()
    
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
    
  errors: (errors) =>
    # Warn that the method was not overridden.
    console.log("!!!!! The errors method was called on controller #{@toString()} but not implemented!!!!!")
  
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
      @timerId = setInterval(
        -> 
          self.refresh.call(self) 
        @refreshInterval
      )
    
  stopTimer: ->
    if @timerId?
      clearInterval(@timerId)
    @timerId = null
