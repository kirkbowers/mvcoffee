ControllerTest.pageLoadCounter = 0

controllerManager = new MVCoffee.ControllerManager
  default_timer_page: ControllerTest.DefaultTimerController
  override_timer_page: ControllerTest.OverrideTimerController
  no_timer_page: ControllerTest.NoTimerController
  no_refresh_page: ControllerTest.NoRefreshController
  timer: ControllerTest.TimeRefreshController
  form_page: ControllerTest.FormController

$ ->
  controllerManager.go()
