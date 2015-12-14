ControllerTest.pageLoadCounter = 0

# It makes sense to turn on debugging in a test app, innit?
runtime = new MVCoffee.Runtime
  debug: true
  clientizeScope: "#clientize_scope"

runtime.register_models
  desert: ControllerTest.Desert
  cactus: ControllerTest.Cactus

runtime.register_controllers
  default_timer_page: ControllerTest.DefaultTimerController
  override_timer_page: ControllerTest.OverrideTimerController
  no_timer_page: ControllerTest.NoTimerController
  no_refresh_page: ControllerTest.NoRefreshController
  timer: ControllerTest.TimeRefreshController
  form_page: ControllerTest.FormController
  plurals_page: ControllerTest.PluralsController

runtime.run()
