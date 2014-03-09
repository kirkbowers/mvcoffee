MVCoffee = require("../lib/mvcoffee")

theUser = class User extends MVCoffee.Model

theUser.validates "number", test: 'numericality'
  
describe "float number", ->
  model = null
  
  beforeEach ->
    model = new User

  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be a number')
    
  it "fails when null", ->
    model.populate({ number: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be a number')
    
  it "fails when blank", ->
    model.populate({ number: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be a number')
    
  it "fails when all letters", ->
    model.populate({ number: "abc" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be a number')
    
  it "passes when zero", ->
    model.populate({ number: "0" });
    expect(model.isValid()).toBeTruthy()
    
  it "passes when a positive integer", ->
    model.populate({ number: "42" });
    expect(model.isValid()).toBeTruthy()
    
  it "passes when a negative integer", ->
    model.populate({ number: "-34" });
    expect(model.isValid()).toBeTruthy()
    
  it "passes when a float", ->
    model.populate({ number: "3.14159" });
    expect(model.isValid()).toBeTruthy()
        
  it "passes when a float in scientific notation", ->
    model.populate({ number: "2.99e8" });
    expect(model.isValid()).toBeTruthy()
        
  it "fail with a float with leading spaces", ->
    model.populate({ number: "  3.14159" });
    expect(! model.isValid()).toBeTruthy()
        
  it "fail with a float with trailing spaces", ->
    model.populate({ number: "3.14159    " });
    expect(! model.isValid()).toBeTruthy()
        
  it "fail with a float with trailing non-numbers", ->
    model.populate({ number: "3.14159a" });
    expect(! model.isValid()).toBeTruthy()

#--------------------------------------------------------

theUser = class UserInt extends MVCoffee.Model

theUser.validates "number", test: 'numericality', only_integer: true
  

describe "integer number", ->
  model = null
  
  beforeEach ->
    model = new UserInt

  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be an integer')
    
  it "fails when null", ->
    model.populate({ number: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be an integer')
    
  it "fails when blank", ->
    model.populate({ number: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be an integer')
    
  it "fails when all letters", ->
    model.populate({ number: "abc" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be an integer')
    
  it "passes when zero", ->
    model.populate({ number: "0" });
    expect(model.isValid()).toBeTruthy()
    
  it "passes when a positive integer", ->
    model.populate({ number: "42" });
    expect(model.isValid()).toBeTruthy()
    
  it "passes when a negative integer", ->
    model.populate({ number: "-34" });
    expect(model.isValid()).toBeTruthy()
    
  it "fails when a float", ->
    model.populate({ number: "3.14159" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be an integer')
        
  it "fail with an int with leading spaces", ->
    model.populate({ number: "  3" });
    expect(! model.isValid()).toBeTruthy()
        
  it "fail with an int with trailing spaces", ->
    model.populate({ number: "3  " });
    expect(! model.isValid()).toBeTruthy()
        
  it "fail with an int with trailing non-numbers", ->
    model.populate({ number: "3a" });
    expect(! model.isValid()).toBeTruthy()


#==============================================================================

theUser = class UserGreaterThan extends MVCoffee.Model

theUser.validates "number", test: 'numericality', greater_than: 11
  


describe "greater than", ->
  
  model = null
  
  beforeEach ->
    model = new UserGreaterThan

  it "doesn't test > when not a number", ->
    model.populate({ number: "abc" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be a number')
    
  it "fails when less than 11", ->
    model.populate({ number: "10.9" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be greater than 11')
    
  it "fails when equal to 11", ->
    model.populate({ number: "11" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be greater than 11')
    
  it "passes when greater than 11", ->
    model.populate({ number: "11.5" });
    expect(model.isValid()).toBeTruthy()
    
# Test subvalidation stuff

theUser = class UserGreaterThanMessage extends MVCoffee.Model

theUser.validates "number", 
  test: 'numericality'
  message: 'has a custom number message'
  greater_than:
    value: 11
    message: "has a custom greater than message" 
  
describe "greater than with subvalidation message", ->
  
  model = null
  
  beforeEach ->
    model = new UserGreaterThanMessage

  it "doesn't test > when not a number", ->
    model.populate({ number: "abc" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number has a custom number message')
    
  it "fails when less than 11", ->
    model.populate({ number: "10.9" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number has a custom greater than message')
    
  it "fails when equal to 11", ->
    model.populate({ number: "11" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number has a custom greater than message')
    
  it "passes when greater than 11", ->
    model.populate({ number: "11.5" });
    expect(model.isValid()).toBeTruthy()
    
    
theUser = class UserGreaterThanOnlyIf extends MVCoffee.Model
  isFluffy: ->
    @fluffy
    
  fluffy: true

theUser.validates "number", 
  test: 'numericality' 
  greater_than:
    value: 11
    only_if: 'isFluffy'
  

describe "greater than with subvalidation only_if", ->
  
  model = null
  
  beforeEach ->
    model = new UserGreaterThanOnlyIf

  it "runs test when fluffy and fails when less than 11", ->
    model.populate({ number: "10.9" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be greater than 11')
    
  it "doesn't run test when not fluffy and less than 11", ->
    model.fluffy = false;
    model.populate({ number: "10.9" });
    expect(model.isValid()).toBeTruthy()
 
    
theUser = class UserGreaterThanUnless extends MVCoffee.Model
  isFluffy: ->
    @fluffy
    
  fluffy: false

theUser.validates "number", 
  test: 'numericality' 
  greater_than:
    value: 11
    unless: 'isFluffy'
  

describe "greater than with subvalidation unless", ->
  
  model = null
  
  beforeEach ->
    model = new UserGreaterThanUnless

  it "runs test when not fluffy and fails when less than 11", ->
    model.populate({ number: "10.9" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be greater than 11')
    
  it "doesn't run test when fluffy and less than 11", ->
    model.fluffy = true;
    model.populate({ number: "10.9" });
    expect(model.isValid()).toBeTruthy()
    
#==============================================================================
# Greater than or equal

theUser = class UserGreaterThanEqual extends MVCoffee.Model

theUser.validates "number", test: 'numericality', greater_than_or_equal_to: 11
  
  
describe "greater than or equal to", ->
  
  model = null
  
  beforeEach ->
    model = new UserGreaterThanEqual

  it "doesn't test >= when not a number", ->
    model.populate({ number: "abc" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be a number')
    
  it "fails when less than 11", ->
    model.populate({ number: "10.9" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be greater than or equal to 11')
        
  it "passes when equal to 11", ->
    model.populate({ number: "11" });
    expect(model.isValid()).toBeTruthy()
    
  it "passes when greater than 11", ->
    model.populate({ number: "11.5" });
    expect(model.isValid()).toBeTruthy()
    
# Test subvalidation stuff
theUser = class UserGreaterThanEqualMessage extends MVCoffee.Model

theUser.validates "number", 
  test: 'numericality'
  message: 'has a custom number message'
  greater_than_or_equal_to:
    value: 11
    message: "has a custom greater than or equal message" 
  

describe "greater than or equal with subvalidation message", ->
  
  model = null
  
  beforeEach ->
    model = new UserGreaterThanEqualMessage

  it "doesn't test > when not a number", ->
    model.populate({ number: "abc" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number has a custom number message')
    
  it "fails when less than 11", ->
    model.populate({ number: "10.9" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number has a custom greater than or equal message')
    
  it "passes when equal to 11", ->
    model.populate({ number: "11" });
    expect(model.isValid()).toBeTruthy()
    
  it "passes when greater than 11", ->
    model.populate({ number: "11.5" });
    expect(model.isValid()).toBeTruthy()



theUser = class UserGreaterThanEqualOnlyIf extends MVCoffee.Model
  isFluffy: ->
    @fluffy
    
  fluffy: true

theUser.validates "number", 
  test: 'numericality' 
  greater_than_or_equal_to:
    value: 11
    only_if: 'isFluffy'
    
describe "greater than or equal with subvalidation only_if", ->
  
  model = null
  
  beforeEach ->
    model = new UserGreaterThanEqualOnlyIf

  it "runs test when fluffy and fails when less than 11", ->
    model.populate({ number: "10.9" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be greater than or equal to 11')
    
  it "doesn't run test when not fluffy and less than 11", ->
    model.fluffy = false;
    model.populate({ number: "10.9" });
    expect(model.isValid()).toBeTruthy()
    
    
    
    
theUser = class UserGreaterThanEqualUnless extends MVCoffee.Model
  isFluffy: ->
    @fluffy
    
  fluffy: false

theUser.validates "number", 
  test: 'numericality' 
  greater_than_or_equal_to:
    value: 11
    unless: 'isFluffy'

describe "greater than or equal with subvalidation unless", ->
  
  model = null
  
  beforeEach ->
    model = new UserGreaterThanEqualUnless

  it "runs test when not fluffy and fails when less than 11", ->
    model.populate({ number: "10.9" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be greater than or equal to 11')
    
  it "doesn't run test when fluffy and less than 11", ->
    model.fluffy = true;
    model.populate({ number: "10.9" });
    expect(model.isValid()).toBeTruthy()
    

    
#==============================================================================

theUser = class UserEqual extends MVCoffee.Model

theUser.validates "number", test: 'numericality', equal_to: 11
  
  
describe "equal to", ->
  
  model = null
  
  beforeEach ->
    model = new UserEqual

  it "doesn't test != when not a number", ->
    model.populate({ number: "abc" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be a number')
    
  it "fails when less than 11", ->
    model.populate({ number: "10.9" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be equal to 11')
        
  it "passes when equal to 11", ->
    model.populate({ number: "11" });
    expect(model.isValid()).toBeTruthy()
    
  it "fails when greater than 11", ->
    model.populate({ number: "11.5" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be equal to 11')
    
# Test subvalidation stuff

theUser = class UserEqualMessage extends MVCoffee.Model

theUser.validates "number", 
  test: 'numericality'
  message: 'has a custom number message'
  equal_to:
    value: 11
    message: "has a custom equal to message" 
  

describe "equal with subvalidation message", ->
  
  model = null
  
  beforeEach ->
    model = new UserEqualMessage

  it "doesn't test != when not a number", ->
    model.populate({ number: "abc" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number has a custom number message')
    
  it "fails when less than 11", ->
    model.populate({ number: "10.9" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number has a custom equal to message')
    
  it "passes when equal to 11", ->
    model.populate({ number: "11" });
    expect(model.isValid()).toBeTruthy()

    
theUser = class UserEqualOnlyIf extends MVCoffee.Model
  isFluffy: ->
    @fluffy
    
  fluffy: true

theUser.validates "number", 
  test: 'numericality' 
  equal_to:
    value: 11
    only_if: 'isFluffy'
  
describe "equal to with subvalidation only_if", ->
  
  model = null
  
  beforeEach ->
    model = new UserEqualOnlyIf


  it "runs test when fluffy and fails when less than 11", ->
    model.populate({ number: "10.9" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be equal to 11')
    
  it "doesn't run test when not fluffy and less than 11", ->
    model.fluffy = false;
    model.populate({ number: "10.9" });
    expect(model.isValid()).toBeTruthy()
    
  


theUser = class UserEqualUnless extends MVCoffee.Model
  isFluffy: ->
    @fluffy
    
  fluffy: false

theUser.validates "number", 
  test: 'numericality' 
  equal_to:
    value: 11
    unless: 'isFluffy'
    
describe "equal to with subvalidation unless", ->
  
  model = null
  
  beforeEach ->
    model = new UserEqualUnless

  it "runs test when not fluffy and fails when less than 11", ->
    model.populate({ number: "10.9" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be equal to 11')
    
  it "doesn't run test when fluffy and less than 11", ->
    model.fluffy = true;
    model.populate({ number: "10.9" });
    expect(model.isValid()).toBeTruthy()
    

#==============================================================================

theUser = class UserLessThan extends MVCoffee.Model

theUser.validates "number", test: 'numericality', less_than: 11

describe "less than", ->
  
  model = null
  
  beforeEach ->
    model = new UserLessThan

  it "doesn't test < when not a number", ->
    model.populate({ number: "abc" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be a number')
    
  it "fails when greater than 11", ->
    model.populate({ number: "11.1" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be less than 11')
    
  it "fails when equal to 11", ->
    model.populate({ number: "11" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be less than 11')
    
  it "passes when less than 11", ->
    model.populate({ number: "10.9" });
    expect(model.isValid()).toBeTruthy()
    
    
# Test subvalidation stuff

theUser = class UserLessThanMessage extends MVCoffee.Model

theUser.validates "number", 
  test: 'numericality'
  message: 'has a custom number message'
  less_than:
    value: 11
    message: "has a custom less than message" 
  
describe "less than with subvalidation message", ->
  
  model = null
  
  beforeEach ->
    model = new UserLessThanMessage

  it "doesn't test < when not a number", ->
    model.populate({ number: "abc" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number has a custom number message')
    
  it "fails when less than 11", ->
    model.populate({ number: "11.9" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number has a custom less than message')
    
  it "fails when equal to 11", ->
    model.populate({ number: "11" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number has a custom less than message')
    
  it "passes when less than 11", ->
    model.populate({ number: "10.5" });
    expect(model.isValid()).toBeTruthy()


theUser = class UserLessThanOnlyIf extends MVCoffee.Model
  isFluffy: ->
    @fluffy
    
  fluffy: true

theUser.validates "number", 
  test: 'numericality' 
  less_than:
    value: 11
    only_if: 'isFluffy'
      
describe "less than with subvalidation only_if", ->
  
  model = null
  
  beforeEach ->
    model = new UserLessThanOnlyIf

  it "runs test when fluffy and fails when less than 11", ->
    model.populate({ number: "11.9" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be less than 11')
    
  it "doesn't run test when not fluffy and less than 11", ->
    model.fluffy = false;
    model.populate({ number: "11.9" });
    expect(model.isValid()).toBeTruthy()
    



theUser = class UserLessThanUnless extends MVCoffee.Model
  isFluffy: ->
    @fluffy
    
  fluffy: false

theUser.validates "number", 
  test: 'numericality' 
  less_than:
    value: 11
    unless: 'isFluffy'
  
describe "less than with subvalidation unless", ->
  
  model = null
  
  beforeEach ->
    model = new UserLessThanUnless

  it "runs test when not fluffy and fails when less than 11", ->
    model.populate({ number: "11.9" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be less than 11')
    
  it "doesn't run test when fluffy and less than 11", ->
    model.fluffy = true;
    model.populate({ number: "11.9" });
    expect(model.isValid()).toBeTruthy()
    
#==============================================================================
  
theUser = class UserLessEqual extends MVCoffee.Model

theUser.validates "number", test: 'numericality', less_than_or_equal_to: 11

describe "less than or equal to", ->
  
  model = null
  
  beforeEach ->
    model = new UserLessEqual

  it "doesn't test <= when not a number", ->
    model.populate({ number: "abc" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be a number')
    
  it "fails when less than 11", ->
    model.populate({ number: "11.1" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be less than or equal to 11')
        
  it "passes when equal to 11", ->
    model.populate({ number: "11" });
    expect(model.isValid()).toBeTruthy()
    
  it "passes when less than 11", ->
    model.populate({ number: "10.5" });
    expect(model.isValid()).toBeTruthy()
    
# Test subvalidation stuff


theUser = class UserLessEqualMessage extends MVCoffee.Model

theUser.validates "number", 
  test: 'numericality'
  message: 'has a custom number message'
  less_than_or_equal_to:
    value: 11
    message: "has a custom less than or equal message" 
  
describe "less than or equal with subvalidation message", ->
  
  model = null
  
  beforeEach ->
    model = new UserLessEqualMessage

  it "doesn't test <= when not a number", ->
    model.populate({ number: "abc" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number has a custom number message')
    
  it "fails when less than 11", ->
    model.populate({ number: "11.9" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number has a custom less than or equal message')
    
  it "passes when equal to 11", ->
    model.populate({ number: "11" });
    expect(model.isValid()).toBeTruthy()
    
  it "passes when less than 11", ->
    model.populate({ number: "10.5" });
    expect(model.isValid()).toBeTruthy()
    


theUser = class UserLessEqualOnlyIf extends MVCoffee.Model
  isFluffy: ->
    @fluffy
    
  fluffy: true

theUser.validates "number", 
  test: 'numericality' 
  less_than_or_equal_to:
    value: 11
    only_if: 'isFluffy'

describe "less than or equal with subvalidation only_if", ->
  
  model = null
  
  beforeEach ->
    model = new UserLessEqualOnlyIf

  it "runs test when fluffy and fails when less than 11", ->
    model.populate({ number: "11.9" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be less than or equal to 11')
    
  it "doesn't run test when not fluffy and less than 11", ->
    model.fluffy = false;
    model.populate({ number: "11.9" });
    expect(model.isValid()).toBeTruthy()
    

theUser = class UserLessEqualUnless extends MVCoffee.Model
  isFluffy: ->
    @fluffy
    
  fluffy: false

theUser.validates "number", 
  test: 'numericality' 
  less_than_or_equal_to:
    value: 11
    unless: 'isFluffy'
  
describe "less than or equal with subvalidation unless", ->
  
  model = null
  
  beforeEach ->
    model = new UserLessEqualUnless
      
  it "runs test when not fluffy and fails when less than 11", ->
    model.populate({ number: "11.9" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be less than or equal to 11')
    
  it "doesn't run test when fluffy and less than 11", ->
    model.fluffy = true;
    model.populate({ number: "11.9" });
    expect(model.isValid()).toBeTruthy()
    

#==============================================================================
  
theUser = class UserOdd extends MVCoffee.Model

theUser.validates "number", test: 'numericality', odd: true
  
describe "odd", ->
  
  model = null
  
  beforeEach ->
    model = new UserOdd

  it "doesn't test odd when not a number", ->
    model.populate({ number: "abc" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be a number')
    
  it "fails when not an integer", ->
    model.populate({ number: "11.1" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be odd')
        
  it "passes when equal to 11", ->
    model.populate({ number: "11" });
    expect(model.isValid()).toBeTruthy()
    
  it "fails when even", ->
    model.populate({ number: "10" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be odd')
    
# Test subvalidation stuff


theUser = class UserOddMessage extends MVCoffee.Model

theUser.validates "number", 
  test: 'numericality'
  message: 'has a custom number message'
  odd:
    message: "has a custom odd message" 
  
describe "odd with subvalidation message", ->
  
  model = null
  
  beforeEach ->
    model = new UserOddMessage

  it "doesn't test odd when not a number", ->
    model.populate({ number: "abc" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number has a custom number message')
    
  it "fails when not an integer", ->
    model.populate({ number: "11.9" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number has a custom odd message')
    
  it "passes when equal to 11", ->
    model.populate({ number: "11" });
    expect(model.isValid()).toBeTruthy()
    
  it "fails when even", ->
    model.populate({ number: "10" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number has a custom odd message')
    


theUser = class UserOddOnlyIf extends MVCoffee.Model
  isFluffy: ->
    @fluffy
    
  fluffy: true

theUser.validates "number", 
  test: 'numericality' 
  odd:
    only_if: 'isFluffy'
  
describe "odd with subvalidation only_if", ->
  
  model = null
  
  beforeEach ->
    model = new UserOddOnlyIf

  it "runs test when fluffy and fails when even", ->
    model.populate({ number: "-4" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be odd')
    
  it "doesn't run test when not fluffy and even", ->
    model.fluffy = false;
    model.populate({ number: "2" });
    expect(model.isValid()).toBeTruthy()
    


theUser = class UserOddUnless extends MVCoffee.Model
  isFluffy: ->
    @fluffy
    
  fluffy: false

theUser.validates "number", 
  test: 'numericality' 
  odd:
    unless: 'isFluffy'
  
describe "odd with subvalidation unless", ->
  
  model = null
  
  beforeEach ->
    model = new UserOddUnless

  it "runs test when not fluffy and fails when even", ->
    model.populate({ number: "4" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be odd')
    
  it "doesn't run test when fluffy and even", ->
    model.fluffy = true;
    model.populate({ number: "4" });
    expect(model.isValid()).toBeTruthy()
    

    

#==============================================================================
  
theUser = class UserEven extends MVCoffee.Model

theUser.validates "number", test: 'numericality', even: true
  
describe "even", ->
  
  model = null
  
  beforeEach ->
    model = new UserEven

  it "doesn't test even when not a number", ->
    model.populate({ number: "abc" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be a number')
    
  it "fails when not an integer", ->
    model.populate({ number: "10.1" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be even')
        
  it "passes when equal to 10", ->
    model.populate({ number: "10" });
    expect(model.isValid()).toBeTruthy()
    
  it "passes when equal to -10", ->
    model.populate({ number: "-10" });
    expect(model.isValid()).toBeTruthy()
    
  it "passes when equal to 0", ->
    model.populate({ number: "0" });
    expect(model.isValid()).toBeTruthy()
    
  it "fails when odd", ->
    model.populate({ number: "11" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be even')
    
# Test subvalidation stuff


theUser = class UserEvenMessage extends MVCoffee.Model

theUser.validates "number", 
  test: 'numericality'
  message: 'has a custom number message'
  even:
    message: "has a custom even message" 

describe "even with subvalidation message", ->
  
  model = null
  
  beforeEach ->
    model = new UserEvenMessage

  it "doesn't test even when not a number", ->
    model.populate({ number: "abc" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number has a custom number message')
    
  it "fails when not an integer", ->
    model.populate({ number: "11.9" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number has a custom even message')
    
  it "passes when equal to 10", ->
    model.populate({ number: "10" });
    expect(model.isValid()).toBeTruthy()
    
  it "fails when odd", ->
    model.populate({ number: "11" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number has a custom even message')
    


theUser = class UserEvenOnlyIf extends MVCoffee.Model
  isFluffy: ->
    @fluffy
    
  fluffy: true

theUser.validates "number", 
  test: 'numericality' 
  even:
    only_if: 'isFluffy'
  
describe "even with subvalidation only_if", ->
  
  model = null
  
  beforeEach ->
    model = new UserEvenOnlyIf

  it "runs test when fluffy and fails when odd", ->
    model.populate({ number: "-11" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be even')
    
  it "doesn't run test when not fluffy and odd", ->
    model.fluffy = false;
    model.populate({ number: "3" });
    expect(model.isValid()).toBeTruthy()
    


theUser = class UserEvenUnless extends MVCoffee.Model
  isFluffy: ->
    @fluffy
    
  fluffy: false

theUser.validates "number", 
  test: 'numericality' 
  even:
    unless: 'isFluffy'
  
describe "even with subvalidation unless", ->
  
  model = null
  
  beforeEach ->
    model = new UserEvenUnless

  it "runs test when not fluffy and fails when odd", ->
    model.populate({ number: "5" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be even')
    
  it "doesn't run test when fluffy and odd", ->
    model.fluffy = true;
    model.populate({ number: "5" });
    expect(model.isValid()).toBeTruthy()
    

#================================================================================
#================================================================================


theUser = class UserInRange extends MVCoffee.Model

theUser.validates "number", 
  test: 'numericality'
  greater_than_or_equal_to: 5 
  less_than_or_equal_to: 11 
  
    
describe "number in a range", ->
  
  model = null
  
  beforeEach ->
    model = new UserInRange

  it "fails when less than bottom of range", ->
    model.populate({ number: "4.9" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be greater than or equal to 5')
    
  it "passes when equal to 5", ->
    model.populate({ number: "5" });
    expect(model.isValid()).toBeTruthy()
    
  it "passes when equal to 7.9", ->
    model.populate({ number: "7.9" });
    expect(model.isValid()).toBeTruthy()
    
  it "passes when equal to 11", ->
    model.populate({ number: "11" });
    expect(model.isValid()).toBeTruthy()

  it "fails when greater than top of range", ->
    model.populate({ number: "11.1" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('Number must be less than or equal to 11')
    



