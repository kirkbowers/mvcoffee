class MVCoffee.ControllerManager
  constructor: (contrs = {}) ->
    @controllers = {}
    @active = []

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

  go: ->
    newActive = []
    for id, contr of @controllers
      if jQuery("##{id}").length > 0
        newActive.push contr
    
    if @active.length
      # We need to start a new controller, so make sure we stop the current ones if 
      # there are any
      @broadcast "stop"

      window.onbeforeunload = null
      window.onfocus = null
      window.onblur = null
      
    if newActive.length
      # console.log("Number of active controllers is " + newActive.length)
      @active = newActive
      @broadcast "start"
      
      window.onfocus = =>
        @broadcast "resume"
      window.onblur = =>
        @broadcast "pause"          
    else
      @active = []

