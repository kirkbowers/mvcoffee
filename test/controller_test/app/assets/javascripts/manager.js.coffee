controllerManager = new MVCoffee.ControllerManager()

controllerManager.addController(
  new ControllerTest.DefaultTimerController("default_timer_page"))
controllerManager.addController(
  new ControllerTest.OverrideTimerController("override_timer_page"))
controllerManager.addController(
  new ControllerTest.NoTimerController("no_timer_page"))
controllerManager.addController(
  new ControllerTest.NoRefreshController("no_refresh_page"))

$ ->
  controllerManager.go()
