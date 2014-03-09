class ControllerTest.TimeRefreshController extends MVCoffee.Controller
  onStart: ->
    @minutes = new Date().getMinutes()
    @refresh()
    
  refreshInterval: 1000

  # Must be a fat rocket because we are working with "this" and the refresh method
  # gets called by the javascript setInterval mechanism, which can mangle "this"    
  refresh: ->
    date = new Date()
    newminutes = date.getMinutes()
    if newminutes isnt @minutes
      @minutes = newminutes
      @manager.broadcast "minutes_changed", @minutes
    
    date = date.toTimeString()
    $("#timer").html("Now is #{date}")
    
  # Note:  there is no "minutes_changed" method on this class.  The exercises what
  # happens on an attempt to broadcast a message that is not recognized by the
  # receiver.  The good news is, nothing happens, no error is thrown because the
  # correct check is being done by the controller manager.