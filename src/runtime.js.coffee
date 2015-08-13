DEFAULT_OPTS =
  debug: false
  clientizeScope: 'body'

class MVCoffee.Runtime
  constructor: (opts = {}) ->
    @opts = DEFAULT_OPTS
    for opt, value of opts
      @opts[opt] = value
    @controllers = {}
    @modelStore = new MVCoffee.ModelStore
    @active = []
    @_flash = {}
    @_oldFlash = {}
    @_clientizeCustomizations = []
    
    # This holds the current state of the session data pulled from the server
    @session = {}
    
    # This is the default html id that is used to pull the json out of a page
    @dataId = "mvcoffee_json"
    
    # Set up for the kludge suggested by David Beck on stackoverflow to detect onfocus
    # correctly on iOS.
    @onfocusId = null



  register_controllers: (contrs) ->
    for id, contr of contrs
      @_addController(new contr(id, this), id)

  _addController: (contr, id) ->
    if id?
      @controllers[id] = contr
    else
      # This is here for backwards compatibility with v0.1
      @controllers[contr.selector] = contr

  register_models: (models) ->
    @modelStore.register_models(models)

  broadcast: (messages, args...) ->
    # In most cases there will be only one message to broadcast, but we want to allow
    # an array of prioritized fallbacks.  The logic is easier if we just always deal with
    # an array, so turn the common case into the easy case.
    unless Array.isArray messages
      messages = [messages]
      
    for controller in @active
      sent = false
      i = 0
      while not sent and i < messages.length
        message = messages[i]
        if message and controller[message]? and typeof controller[message] is 'function'
          sent = true
          controller[message].apply(controller, args)
        i++
      
  _recycleFlash: ->
    # Recycle the flash
    @_oldFlash = @_flash
    @_flash = {}

  setFlash: (opts) =>
    for key, opt of opts
      @_flash[key] = opt
      
  getFlash: (key) =>
    @_flash[key] ? @_oldFlash[key]
    
  setSession: (opts) =>
    for key, opt of opts
      @session[key] = opt

  getSession: (key) =>
    @session[key]
    
  getErrors: =>
    @errors

  # This method returns false if a redirect is issued, meaning only continue processing
  # if true is returned.
  _preProcessServerData: (data) =>
    # If we didn't get anything from the server, do nothing
    if data
      if @opts.debug
        console.log("Got data from server: " + JSON.stringify(data))
    
      # First load the model store.  This will do a check that the data format is as
      # expected and throw an exception if not.
      @modelStore.load(data)
    
      # We need to process the volatile data
      if data.flash?
        @setFlash(data.flash)
      if data.session?
        for key, value of data.session
          @log "Setting session value #{key} to value #{value} from server"
          @session[key] = value
      @errors = data.errors
    
      # If a redirect was issued, that trumps calling any callbacks
      if data.redirect?
        Turbolinks.visit(data.redirect)
        return false
      else
        return true
    else
      # This used to by "false".  I don't remember why.  It caused the controller_test
      # pre-rolled blackbox test to do nothing, because there's no data from the
      # server.  This isn't the behavior we want.  We should be able to fire 
      # controllers on a data-free page.
      true

  processServerData: (data, callback_message = "") =>
    if @_preProcessServerData data
      # If no redirect was issued, call either the success or failure callback
      if @errors
        # This guards against both undefined and empty string
        if callback_message
          error_callback_message = ["#{callback_message}_errors", "errors"]
        else
          error_callback_message = "errors"
        end
        @broadcast error_callback_message, @errors
      else
        # If there is a success callback implemented for this form that was submitted,
        # give that priority and give it the choice whether to call render or not.
        # Otherwise, always render as a fallback.
        @broadcast [callback_message, "render"]
    
  log: (message) =>
    if @opts.debug
      console.log message
  
  go: ->
    @log "MVCoffee runtime firing 'go'"
    
    # First thing we want to do is get the authenticity token that rails supplies,
    # just in case this is rails on the backend
    token = jQuery("meta[name='csrf-token']")
    if token?.length
      @authenticity_token = token.attr("content");
      
    # Clear the session cookie
    document.cookie = "mvcoffee_session="

    @_recycleFlash()
  
    # Reset the clientize customizations before we start this pages controllers.
    # Controllers add their own clientize customizations as part of their start up.
    @resetClientizeCustomizations()
  
    # Pull the json from the page if there is some embedded
    json = $("##{@dataId}").html()

    parsed = null
    if json
      parsed = $.parseJSON(json)
    if @_preProcessServerData(parsed)  
      newActive = []
      for id, contr of @controllers
        if jQuery("##{id}").length > 0
          @log "Starting controller identified by " + id
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
        @active = newActive
        @broadcast "start"
      
        window.onfocus = =>
          @_startSafariKludge()
          @broadcast "resume"
        window.onblur = =>
          @_stopSafariKludge()
          @broadcast "pause"    
        
        @_startSafariKludge()
      else
        @active = []
        
      # Now that the new controllers have been started, it's time to clientize the 
      # current page with our own additional unobtrusive javascript
      @clientize()

  _startSafariKludge: ->
    @_stopSafariKludge()
  
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
    
  _stopSafariKludge: ->
    if @onfocusId?
      clearInterval(@onfocusId)
    @onfocusId = null


  #---------------------------------------------------------------------------
  # "clientize" adds unobtrusive javascript to do two things:
  # - keep us on the client entirely if possible.  Out of the box, turbolinks only 
  #   adds ujs to get anchors, but not forms nor post or delete anchors.
  # - send back client side session data back to server.  If we have a time stamp of
  #   the cache age on the client, we need to send this back.  Of course, we don't want
  #   to have to think about sending it back, so this does it automagically.
  #
  # This is a "public" method, in that I don't prefix it with an underscore, but you
  # probably never have to call it manually.  It's called for you at the correct time
  # as part of the runtime's "go" action.
  
  clientize: ->
    @log ">>> begin clientize"
    if Turbolinks?
      self = this
      
      $searchInside = jQuery(@opts.clientizeScope)

      # We want to add our own "unobtrusive" javascript on every form on the page
      $searchInside.find("form").each (index, element) =>
        self.log "clientizing form with action " + jQuery(element).attr("action")

        customization = {}
        for thisCustom in @_clientizeCustomizations
          # The allowed customizations are "confirm" and "model"
          if $(element).is(thisCustom.selector)
            customization = thisCustom

        unless customization.ignore? is true
          $(element).submit ->
            doPost = true
            self.log "Submitting for selector " + customization.selector
            # The "model" customization performs validation with the supplied
            # model instance.  NOTE:  it must be an instance, not a model 
            # constructor function.
            # If validation fails, the method that matches the form's id with
            # _errors appended will be called with the errors array.
            model = customization.model
            self.log "model = " + model
            if model?
              model.populate()
              method = "#{element.id}_errors"
              if customization.controller?[method]?
                customization.controller?[method](model.errors)
              else
                console.log("!!! method #{method} not implemented !!!")
            
              doPost = model.isValid()

            # The "confirm" customization pops up a confirm dialog
            confirm = customization.confirm
            self.log "confirm customization = " + confirm
            if doPost and confirm?
              if confirm instanceof Function
                doPost = confirm()
              else
                doPost = window.confirm(confirm)
                      
            if doPost
              if element.method is "get" or element.method is "GET"
                self.visit element.action
              else            
                self.submit element
            
            # Always return false to supress a true post 
            false

      # We also want to do our own unobtrusive javascript on all anchor tags.
      # This is a bit non-DRY, but slightly different things happen on anchor
      # tags as on forms.  For the moment I can live with it, but I'll probably clean
      # this up at some point.  It is less than ideal that it currently does not allow
      # a confirm message from the customization...    
      $searchInside.find("a").each (index, element) =>
        self.log "clientizing anchor " + element.id
        customization = {}
        for thisCustom in @_clientizeCustomizations
          # The allowed customizations are "confirm" and "model"
          if $(element).is(thisCustom.selector)
            customization = thisCustom

        unless customization.ignore? is true
          jQuery(element).click( =>
            doPost = true
            # The "confirm" customization pops up a confirm dialog
            confirm = jQuery(element).data("confirm")
            if confirm?
              doPost = window.confirm(confirm)

            if doPost
              method = $(element).attr('data-method')
              self.log "Data method = " + method
              if method is "post"
                self.post(element.href, element.id)
              else if method is "delete"
                self.delete(element.href, element.id)
              else
                self.visit(element.href)
            false
          )
    @log "<<< end clientize"


  resetClientizeCustomizations: ->
    @_clientizeCustomizations = []  

  addClientizeCustomization: (customization) ->
    @_clientizeCustomizations.push customization
    
  dontClientize: (selector) =>
    @_clientizeCustomizations.push
      selector: selector
      ignore: true

  #---------------------------------------------------------------------------
  # 
  # Methods for getting and posting to the server
  #
  # In MVCoffee land, you should never have to call ajax to your own server manually,
  # unless you're talking to some legacy non-MVCoffee routes.  Instead, you should
  # always use the methods supplied here.
  # For one, they automate for you sending the client session data back to the server,
  # which is useful for determining if the cache is out of date or not.
  # For two, they also automate processing the data sent from the server.  This will
  # make sure the cache, session and flash are properly populated, plus it will handle
  # any client-side redirects issued by the server.

  _setSessionCookie: ->
    params = jQuery.param(@session)
    expiration = new Date()
    expiration.setTime(expiration.getTime() + 2000)
    document.cookie = "mvcoffee_session=#{params}; expires=#{expiration}"
                  
                  
  # There is no "get" method.  Instead the functionality of "get" is provided by two
  # different methods, visit and fetch.  "visit" is a "get" over regular html, meaning
  # _visit_ this page.  "fetch" is a "get" over ajax, meaning _fetch_ the data that
  # this url provides in json format, but do not navigate anywhere (unless the fetched
  # data contains a redirect instruction).
                  
  visit: (url) =>
    # We're recycling the flash here because it should only persist through a redirect.
    @_recycleFlash()
    @_setSessionCookie()
    Turbolinks.visit url

  fetch: (url, callback_message = "render") =>
    @_setSessionCookie()
    jQuery.get(url,
      null,
      (data) =>
        @processServerData data, callback_message
      ,
      'json')

  # "post" is also broken into two different versions, but unlike the "visit" method,
  # there is no method that involves navigation.  "post" simply calls a post over ajax
  # to the url supplied.  "submit" submits the form referenced by the DOM element
  # or jQuery object supplied over ajax.

  post: (url, callback_message = "") =>
    @_setSessionCookie()
    self = this
    jQuery.ajax(
      url: url,
      type: 'POST',
      success: (data) =>
        self.processServerData(data, callback_message)
      dataType: "json"
    )

  submit: (submitee) =>
    @_setSessionCookie()
    element = submitee
    if submitee instanceof jQuery
      element = submitee.get(0)
    jQuery.post(element.action,
      $(element).serialize(),
      (data) =>
        @processServerData(data, element.id)
      ,
      'json')
    false

  delete: (url, callback_message = "") =>
    @_setSessionCookie()
    self = this
    jQuery.ajax(
      url: url,
      type: 'DELETE',
      success: (data) =>
        self.processServerData(data, callback_message)
      dataType: "json"
    )



  #---------------------------------------------------------------------------
  # "run" starts the whole runtime.  
  
  run: ->
    @log "MVCoffee runtime run"
    self = this
    $ ->
      self.go()

    $(document).on('pagebeforeshow', ->
      self.go()
    )