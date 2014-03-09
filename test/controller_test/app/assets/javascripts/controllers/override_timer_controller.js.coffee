class ControllerTest.OverrideTimerController extends MVCoffee.Controller
  onStart: ->
    date = new Date().toTimeString()
    $(".override_timer").append("<li>Override Timer Started at #{date}</li>")
    
  refreshInterval: 5000
    
  refresh: ->
    date = new Date().toTimeString()
    $(".override_timer").append("<li>Override Timer refresh at #{date}</li>")
        
  minutes_changed: (minutes) ->
    date = new Date().toTimeString()
    $(".override_timer").append("<li>Override Timer received minutes changed to #{minutes} at #{date}</li>")
