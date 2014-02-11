class MVCoffee.ControllerManager
  controllers: []
  active: null

  addController: (contr) ->
    @controllers.push(contr)

  go: ->
    newActive = null
    for contr in @controllers
      if jQuery(contr.selector).length > 0
        newActive = contr
    
    if @active? and @active isnt newActive
      # We need to start a new controller, so make sure we stop the current one if 
      # this is one
      @active.stop()
      window.onbeforeunload = null
      
    if newActive?
      if @active isnt newActive
        @active = newActive
        @active.start()
        window.onbeforeunload = =>
          @active.stop()
    else
      @active = null

class MVCoffee.Controller
  constructor: (@id) ->
    @selector = "body#" + @id
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

      window.onfocus = =>
        # Related to the comment above, if isActive is true, we're already sitting on
        # this page the window already has focus, so don't refresh unnecessarily.
        unless @isActive
          @isActive = true
          @refresh()
          @startTimer()
        
      window.onblur = =>
        @isActive = false
        @stopTimer()
        
      
  stop: ->
    @isActive = false
    @onStop()
    
    if @refresh?
      @stopTimer()
      window.onfocus = null
      window.onblur = null
  
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
      @timerId = setInterval(@refresh, @refreshInterval)
    
  stopTimer: ->
    if @timerId?
      clearInterval(@timerId)
    @timerId = null
