class ControllerTest.TimeRefreshController extends MVCoffee.Controller
  onStart: ->
    @refresh()
    
  refreshInterval: 1000
    
  refresh: ->
    date = new Date().toTimeString()
    $("#timer").html("Now is #{date}")
    
