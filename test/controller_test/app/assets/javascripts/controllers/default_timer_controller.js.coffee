class ControllerTest.DefaultTimerController extends MVCoffee.Controller
  onStart: ->
    date = new Date().toTimeString()
    $(".default_timer").append("<li>Default Timer Started at #{date}</li>")
    
  refresh: ->
    date = new Date().toTimeString()
    $(".default_timer").append("<li>Default Timer refresh at #{date}</li>")
    
