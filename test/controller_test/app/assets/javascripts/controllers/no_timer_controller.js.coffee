class ControllerTest.NoTimerController extends MVCoffee.Controller
  onStart: ->
    date = new Date().toTimeString()
    $(".no_timer").append("<li>No Timer Started at #{date}</li>")
    
  refreshInterval: 0  
  
  refresh: ->
    date = new Date().toTimeString()
    $(".no_timer").append("<li>No Timer refresh at #{date}</li>")
        
  minutes_changed: (minutes) ->
    date = new Date().toTimeString()
    $(".no_timer").append("<li>No Timer received minutes changed to #{minutes} at #{date}</li>")
