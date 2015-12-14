class ControllerTest.PluralsController extends MVCoffee.Controller
  onStart: ->
    # Populate with some silly data
    
    @desert = new ControllerTest.Desert
      id: 1
      name: 'Sonoran'
    @desert.save()
    
    cactus1 = new ControllerTest.Cactus
      id: 1
      desert_id: 1
      name: 'Saguara'
    cactus1.save()
      
    cactus2 = new ControllerTest.Cactus
      id: 2
      desert_id: 1
      name: 'Barrel'
    cactus2.save()
      
    console.log "Plural of cactus is " + MVCoffee.Pluralizer.pluralize('cactus')
    
  render: ->
    $("#desert_name").html("Desert name: " + @desert.name)
    
    $cacti_list = $("ul#cacti")
    
    $cacti_list.empty()
    
    # Note the irregular plural!
    for cactus in @desert.cacti()
      $cacti_list.append("<li>" + cactus.name + "</li>")