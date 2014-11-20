class MVCoffee.ControllerManager
  constructor: (contrs = {}) ->
    @controllers = {}
    @active = []
    @_flash = {}
    @_oldFlash = {}
    
    # This holds the current state of the session data pulled from the server
    @session = {}
    
    # This is the default html id that is used to pull the json out of a page
    @dataId = "mvcoffee_json"
    
    # This should be overridden in your master file to point to your project's
    # actual model store.  This is just here to keep things from bombing
    # completely if you don't set one.
    @modelStore = new MVCoffee.ModelStore
    console.log("Model store = " + @modelStore)

    # Set up for the kludge suggested by David Beck on stackoverflow to detect onfocus
    # correctly on iOS.
    @onfocusId = null

    # console.log("controller manager constructor, #{contrs}")

    for id, contr of contrs
      @addController(new contr(id, this), id)


  addController: (contr, id) ->
    # console.log("adding controller with id #{id}")
    if id?
      @controllers[id] = contr
    else
      # This is here for backwards compatibility with v0.1
      @controllers[contr.selector] = contr

  broadcast: (message, args...) ->
    for controller in @active
      if controller[message]? and typeof controller[message] is 'function'
        controller[message].apply(controller, args)
        
  setFlash: (opts) =>
    for key, opt of opts
      @_flash[key] = opt
      
  getFlash: (key) =>
    @_flash[key] ? @_oldFlash[key]

  getSession: (key) =>
    @session[key]
    
  getErrors: =>
    @errors

  processServerData: (data, callback_message = "") =>
    # If we didn't get anything from the server, do nothing
    if data
      console.log("Got data from server: " + JSON.stringify(data))
      console.log("Model store = " + @modelStore)
    
      # First load the model store.  This will do a check that the data format is as
      # expected and throw an exception if not.
      @modelStore.load(data)
    
      # We need to process the volatile data
      if data.flash?
        @setFlash(data.flash)
      if data.session?
        for key, value of data.session
          @session[key] = value
      @errors = data.errors
    
      # If a redirect was issued, that trumps calling any callbacks
      if data.redirect?
        Turbolinks.visit(data.redirect)
      else if callback_message
        # But if no redirect was issued, call either the success or failure callback
        if @errors
          error_callback_message = "#{callback_message}_errors"
          @broadcast error_callback_message, @errors
        else
          @broadcast callback_message
    
  go: ->
    # Recycle the flash
    @_oldFlash = @_flash
    @_flash = {}
  
    # Pull the json from the page if there is some embedded
    json = $("##{@dataId}").html()
    # console.log("Client json = " + json)
    parsed = null
    if json
      parsed = $.parseJSON(json)
    # console.log("Server json: " + JSON.stringify(parsed))
    @processServerData(parsed)
    # console.log("model store = " + JSON.stringify(@modelStore.store))
  
    newActive = []
    for id, contr of @controllers
      if jQuery("##{id}").length > 0
        # console.log("Found id for controller " + id)
        newActive.push contr
    
    if @active.length
      # We need to start a new controller, so make sure we stop the current ones if 
      # there are any
      @broadcast "stop"

      window.onbeforeunload = null
      window.onfocus = null
      window.onblur = null
      
      if @onfocusId
        clearInterval(@onfocusId)
      @onfocusId = null
      
    if newActive.length
      # console.log("Number of active controllers is " + newActive.length)
      @active = newActive
      @broadcast "start"
      
      window.onfocus = =>
        @broadcast "resume"
      window.onblur = =>
        @broadcast "pause"    
        
      # This is a total kludge added in 0.3.1 to detect onfocus events in iOS
      # Normally iOS safari does not fire onfocus when the tab is changed or it safari
      # is relaunched from the background.
      # However, as pointed out by David Beck on stackoverflow 
      # http://stackoverflow.com/questions/4656387/how-to-detect-in-ios-webapp-when-switching-back-to-safari-from-background
      # the timer is suspended.  So you can detect if the window has lost focus for some 
      # amount of time by checking if the time since the last fire of a time is grossly
      # longer than the timer is set for.
      @lastFired = new Date().getTime()
      @onfocusId = setInterval(=>
        now = new Date().getTime()
        if now - @lastFired > 2000
          @broadcast "pause"
          @broadcast "resume"
        @lastFired = now
      , 500)
      
    else
      @active = []

