ControllerTest.pageLoadCounter = 0

runtime = new MVCoffee.Runtime

runtime.register_controllers
  default_timer_page: ControllerTest.DefaultTimerController
  override_timer_page: ControllerTest.OverrideTimerController
  no_timer_page: ControllerTest.NoTimerController
  no_refresh_page: ControllerTest.NoRefreshController
  timer: ControllerTest.TimeRefreshController
  form_page: ControllerTest.FormController

runtime.run()
