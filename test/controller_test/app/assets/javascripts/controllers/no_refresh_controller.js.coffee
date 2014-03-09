class ControllerTest.NoRefreshController extends MVCoffee.Controller
  onStart: ->
    date = new Date().toTimeString()
    $(".no_refresh").append("<li>No Refresh Started at #{date}</li>")
    
  minutes_changed: (minutes) ->
    date = new Date().toTimeString()
    $(".no_refresh").append("<li>No Refresh received minutes changed to #{minutes} at #{date}</li>")
    
