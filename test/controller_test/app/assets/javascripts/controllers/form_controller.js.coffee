class ControllerTest.FormController extends MVCoffee.Controller
  onStart: ->
    @thing = new ControllerTest.Thing
    
    @addClientizeCustomization
      selector: '#confirm_post_button'
      confirm: 'Are you sure?'
      
    @addClientizeCustomization
      selector: '#thing_form'
      model: @thing

    @addClientizeCustomization
      selector: '#delete_anchor_link_with_confirm'
      confirm: 'Are you sure you want to delete from a clientized delete link?'
    
    @dontClientize "#toggle"
    $("#toggle").click( ->
      $("p#toggle-message").toggle(500)
      false
    )  
  
    @dontClientize "#refresh"
    $("#refresh").click( =>
      @fetch "/form/index"
      false
    )  
  
  thing_form_errors: (errors) ->
    $errors = $("#thing-errors")
    $errors.empty()
    
    for error in errors
      $errors.append("<li>#{error}</li>")

  render: ->
    ControllerTest.pageLoadCounter += 1
    $("#page-loads").html("Number of page loads: #{ControllerTest.pageLoadCounter}")
    $("#flash").html(@getFlash("message"))
    $("#cache-status").html(@getFlash("cache_status"))
  