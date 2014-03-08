class MVCoffee.ControllerManager
  constructor: (contrs = {}) ->
    @controllers = {}
    @active = null

    console.log("controller manager constructor, #{contrs}")

    for id, contr of contrs
      @addController(new contr, id)


  addController: (contr, id) ->
    console.log("adding controller with id #{id}")
    if id?
      @controllers[id] = contr
    else
      # This is here for backwards compatibility with v0.1
      @controllers[contr.selector] = contr

  go: ->
    newActive = null
    for id, contr of @controllers
      console.log("looking for id -#{id}-")
      if jQuery("body##{id}").length > 0
        console.log("found it")
        newActive = contr
    
    if @active?
      # We need to start a new controller, so make sure we stop the current one if 
      # this is one
      @active.stop()
      window.onbeforeunload = null
      
    if newActive?
      @active = newActive
      @active.start()
      window.onbeforeunload = =>
        @active.stop()
    else
      @active = null

