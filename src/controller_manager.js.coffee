class MVCoffee.ControllerManager
  constructor: (contrs = {}) ->
    @controllers = {}
    @active = []

    # console.log("controller manager constructor, #{contrs}")

    for id, contr of contrs
      @addController(new contr, id)


  addController: (contr, id) ->
    # console.log("adding controller with id #{id}")
    if id?
      @controllers[id] = contr
    else
      # This is here for backwards compatibility with v0.1
      @controllers[contr.selector] = contr

  go: ->
    newActive = []
    for id, contr of @controllers
      if jQuery("##{id}").length > 0
        newActive.push contr
    
    if @active?
      # We need to start a new controller, so make sure we stop the current one if 
      # this is one
      for contr in @active
        contr.stop()
      window.onbeforeunload = null
      window.onfocus = null
      window.onblur = null
      
    if newActive.length
      # console.log("Number of active controllers is " + newActive.length)
      @active = newActive
      for contr in @active
        contr.start()
      # Turns out we don't need to do this onbeforeunload.
      # Everything will just stop anyway as javascript is purged from memory
      #       window.onbeforeunload = =>
      #         for contr in @active
      #           contr.stop()
      window.onfocus = =>
        for contr in @active
          contr.resume()
      window.onblur = =>
        for contr in @active
          contr.pause()
          
    else
      @active = []

