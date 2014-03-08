MVCoffee = require("../lib/mvcoffee")

theUser = class User extends MVCoffee.Model

theUser.validates "my_field", test: "acceptance"

# The idea with the model name "my_field" is that we can exercise the trick to map
# the field name to a human readable format if the "display" is not suppled.
describe "acceptance, simple case", ->
  model = null

  beforeEach ->
    model = new User

  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be accepted')

  it "fails when null", ->
    model.populate({ my_field: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be accepted')

  it "fails when blank", ->
    model.populate({ my_field: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be accepted')

  it "fails when 0", ->
    model.populate({ my_field: "0" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be accepted')


  it "passes when 1", ->
    model.populate({ my_field: "1" });
    expect(model.isValid()).toBeTruthy()
    
#==============================================================================
# Try with a custom message

theUser = class UserWithMessage extends MVCoffee.Model

theUser.validates "my_field", test: "acceptance", message: 'must be complied with'
  
describe "acceptance, custom message", ->
  model = null
  beforeEach ->
    model = new UserWithMessage

  it "fails when 0", ->
    model.populate({ my_field: "0" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be complied with')


  it "passes when 1", ->
    model.populate({ my_field: "1" });
    expect(model.isValid()).toBeTruthy()


#==============================================================================
# Try with a custom display name
  
theUser = class UserWithDisplay extends MVCoffee.Model

theUser.displays "my_field", "Massive red tape"
theUser.validates "my_field", test: "acceptance"
  
describe "acceptance, custom display name", ->
  model = null
  
  beforeEach ->
    model = new UserWithDisplay

  it "fails when 0", ->
    model.populate({ my_field: "0" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Massive red tape must be accepted')


  it "passes when 1", ->
    model.populate({ my_field: "1" });
    expect(model.isValid()).toBeTruthy()

#==============================================================================
# Try with a custom display name and custom message
 
theUser = class UserWithDisplayAndMessage extends MVCoffee.Model

theUser.displays "my_field", "Massive red tape"
theUser.validates "my_field", test: "acceptance", message: 'must be complied with'
   
describe "acceptance, custom display name", ->
  model = null
  
  beforeEach ->
    model = new UserWithDisplayAndMessage

  it "fails when 0", ->
    model.populate({ my_field: "0" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Massive red tape must be complied with')


  it "passes when 1", ->
    model.populate({ my_field: "1" });
    expect(model.isValid()).toBeTruthy()


#==============================================================================
# Try with an only_if

theUser = class UserWithOnlyIf extends MVCoffee.Model
  isFluffy: ->
    @fluffy
    
  fluffy: true
  

theUser.validates "my_field", test: "acceptance", only_if: "isFluffy"

describe "acceptance, only_if", ->
  model = null

  beforeEach ->
    model = new UserWithOnlyIf

  it "fails when 0 and fluffy", ->
    model.populate({ my_field: "0" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be accepted')

  it "passes when 1 and fluffy", ->
    model.populate({ my_field: "1" });
    expect(model.isValid()).toBeTruthy()

  it "passes when 0 and not fluffy", ->
    model.fluffy = false;
    model.populate({ my_field: "0" });
    expect(model.isValid()).toBeTruthy()

#==============================================================================
# Try with an unless
  
theUser = class UserWithUnless extends MVCoffee.Model
  isFluffy: ->
    @fluffy
    
  fluffy: false
  

theUser.validates "my_field", test: "acceptance", unless: "isFluffy"

describe "acceptance, custom message", ->
  model = null
  
  beforeEach ->
    model = new UserWithUnless

  it "fails when 0 and not fluffy", ->
    model.populate({ my_field: "0" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be accepted')

  it "passes when 1 and not fluffy", ->
    model.populate({ my_field: "1" });
    expect(model.isValid()).toBeTruthy()

  it "passes when 0 and fluffy", ->
    model.fluffy = true;
    model.populate({ my_field: "0" });
    expect(model.isValid()).toBeTruthy()

#==============================================================================
# Try with both an only_if and unless
  
theUser = class UserWithOnlyIfAndUnless extends MVCoffee.Model
  isRotten: ->
    @rotten

  isFluffy: ->
    @fluffy
    
  rotten: true
  fluffy: false
  

theUser.validates "my_field",
  test: "acceptance"
  only_if: "isRotten"
  unless: "isFluffy"


describe "acceptance, custom message", ->
  model = null
  
  beforeEach ->
    model = new UserWithOnlyIfAndUnless

  it "fails when 0, rotten and not fluffy", ->
    model.populate({ my_field: "0" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be accepted')

  it "passes when 1, rotten and not fluffy", ->
    model.populate({ my_field: "1" });
    expect(model.isValid()).toBeTruthy()

  it "passes when 0, rotten and fluffy", ->
    model.fluffy = true;
    model.populate({ my_field: "0" });
    expect(model.isValid()).toBeTruthy()

  it "passes when 0, not rotten and not fluffy", ->
    model.rotten = false;
    model.populate({ my_field: "0" });
    expect(model.isValid()).toBeTruthy()

  it "passes when 0, not rotten and fluffy", ->
    model.rotten = false;
    model.fluffy = true;
    model.populate({ my_field: "0" });
    expect(model.isValid()).toBeTruthy()


#==============================================================================
# Try with allow_null

theUser = class UserWithAllowNull extends MVCoffee.Model

theUser.validates "my_field", test: "acceptance", allow_null: true
   
describe "acceptance, allow null", ->
  model = null
  
  beforeEach ->
    model = new UserWithAllowNull

  it "passes when undefined", ->
    model.validate();
    expect(model.isValid()).toBeTruthy()

  it "passes when null", ->
    model.populate({ my_field: null });
    expect(model.isValid()).toBeTruthy()

  it "fails when blank", ->
    model.populate({ my_field: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be accepted')

  it "fails when 0", ->
    model.populate({ my_field: "0" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be accepted')


  it "passes when 1", ->
    model.populate({ my_field: "1" });
    expect(model.isValid()).toBeTruthy()
    
#==============================================================================
# Try with allow_blank
  
theUser = class UserWithAllowBlank extends MVCoffee.Model

theUser.validates "my_field", test: "acceptance", allow_blank: true
   
describe "acceptance, allow blank", ->
  model = null
  
  beforeEach ->
    model = new UserWithAllowBlank

  it "passes when undefined", ->
    model.validate();
    expect(model.isValid()).toBeTruthy()

  it "passes when null", ->
    model.populate({ my_field: null });
    expect(model.isValid()).toBeTruthy()

  it "passes when blank", ->
    model.populate({ my_field: "" });
    expect(model.isValid()).toBeTruthy()

  it "fails when 0", ->
    model.populate({ my_field: "0" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be accepted')


  it "passes when 1", ->
    model.populate({ my_field: "1" });
    expect(model.isValid()).toBeTruthy()
    
#==============================================================================
# Try with custom accept flag
  
theUser = class UserWithCustomAccept extends MVCoffee.Model

theUser.validates "my_field", test: "acceptance", accept: 'yes'
   
describe "acceptance, custom accept", ->
  model = null
  
  beforeEach ->
    model = new UserWithCustomAccept

  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be accepted')

  it "fails when null", ->
    model.populate({ my_field: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be accepted')

  it "fails when blank", ->
    model.populate({ my_field: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be accepted')

  it "fails when 0", ->
    model.populate({ my_field: "0" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be accepted')

  it "fails when 1", ->
    model.populate({ my_field: "1" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be accepted')


  it "passes when yes", ->
    model.populate({ my_field: "yes" });
    expect(model.isValid()).toBeTruthy()
    
