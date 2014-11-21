class ControllerTest.FormController extends MVCoffee.Controller
  onStart: ->
    ControllerTest.pageLoadCounter += 1
    $("#page-loads").html("Number of page loads: #{ControllerTest.pageLoadCounter}")
    $("#flash").html(@getFlash("message"))
    
    @thing = new ControllerTest.Thing
    
    
    @turbolinkForms(
      confirm_post_button:
        confirm: 'Are you sure?'
      thing_form:
        model: @thing
    )

  
  thing_form_errors: (errors) ->
    $errors = $("#thing-errors")
    $errors.empty()
    
    for error in errors
      $errors.append("<li>#{error}</li>")
