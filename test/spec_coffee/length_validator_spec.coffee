MVCoffee = require("../lib/mvcoffee")

theUser = class User extends MVCoffee.Model

theUser.validates 'my_field', test: 'length', minimum: 3
  
describe "length minimum, default message", ->
  model = null
  
  beforeEach ->
    model = new User

  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is too short (minimum is 3 characters)')

  it "fails when null", ->
    model.populate({ my_field: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is too short (minimum is 3 characters)')

  it "fails when blank", ->
    model.populate({ my_field: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is too short (minimum is 3 characters)')

  it "fails when one char long", ->
    model.populate({ my_field: "a" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is too short (minimum is 3 characters)')

  it "fails when two chars long", ->
    model.populate({ my_field: "ab" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is too short (minimum is 3 characters)')

  it "passes when three chars long", ->
    model.populate({ my_field: "abc" });
    expect(model.isValid()).toBeTruthy()

  it "passes when really long", ->
    model.populate({ my_field: "This is a really long string" });
    expect(model.isValid()).toBeTruthy()

#----------------------------------------------------------

theUser = class UserMinLengthWithMessage extends MVCoffee.Model

theUser.validates 'my_field', 
  test: 'length'
  minimum:
    value: 3
    message: "must be at least 3 characters"

describe "length minimum, custom message", ->
  model = null
  
  beforeEach ->
    model = new UserMinLengthWithMessage

  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at least 3 characters')

  it "fails when null", ->
    model.populate({ my_field: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at least 3 characters')

  it "fails when blank", ->
    model.populate({ my_field: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at least 3 characters')

  it "fails when one char long", ->
    model.populate({ my_field: "a" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at least 3 characters')

  it "fails when two chars long", ->
    model.populate({ my_field: "ab" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at least 3 characters')

  it "passes when three chars long", ->
    model.populate({ my_field: "abc" });
    expect(model.isValid()).toBeTruthy()

  it "passes when really long", ->
    model.populate({ my_field: "This is a really long string" });
    expect(model.isValid()).toBeTruthy()



#----------------------------------------------------------

theUser = class UserMinLengthWithTokenizer extends MVCoffee.Model

theUser.validates 'my_field', 
  test: 'length'
  tokenizer: (val) ->
    val.split /\s+/
  minimum:
    value: 3
    message: "must be at least 3 words"

describe "length minimum, custom tokenizer", ->
  model = null
  
  beforeEach ->
    model = new UserMinLengthWithTokenizer

  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at least 3 words')

  it "fails when null", ->
    model.populate({ my_field: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at least 3 words')

  it "fails when blank", ->
    model.populate({ my_field: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at least 3 words')

  it "fails when one char long", ->
    model.populate({ my_field: "a" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at least 3 words')

  it "fails when two chars long", ->
    model.populate({ my_field: "ab" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at least 3 words')

  it "fails when three chars long", ->
    model.populate({ my_field: "abc" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at least 3 words')

  it "fails when two words long", ->
    model.populate({ my_field: "Two words" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at least 3 words')

  it "passes when three words long", ->
    model.populate({ my_field: "Three words long" });
    expect(model.isValid()).toBeTruthy()
    
  it "passes when three words long with extra spaces", ->
    model.populate({ my_field: "Three     words   long" });
    expect(model.isValid()).toBeTruthy()

  it "passes when really long", ->
    model.populate({ my_field: "This is a really long string, I mean it is really long!" });
    expect(model.isValid()).toBeTruthy()

#----------------------------------------------------------

theUser = class UserMinLengthOnlyIf extends MVCoffee.Model
  shouldDoIt: ->
    @do_it

theUser.validates 'my_field', 
  test: 'length'
  minimum:
    value: 3
    only_if: "shouldDoIt"

describe "length minimum with only_if", ->
  model = null
  
  beforeEach ->
    model = new UserMinLengthOnlyIf

  it "fails when two chars long and do it is true", ->
    model.do_it = true;
    model.populate({ my_field: "ab" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is too short (minimum is 3 characters)')

  it "passes when two chars long and do it is false", ->
    model.do_it = false;
    model.populate({ my_field: "ab" });
    expect(model.isValid()).toBeTruthy()

#----------------------------------------------------------

theUser = class UserMinLengthWithUnless extends MVCoffee.Model
  shouldntDoIt: ->
    @do_it

theUser.validates 'my_field', 
  test: 'length'
  minimum:
    value: 3
    unless: "shouldntDoIt"

describe "length minimum with unless", ->
  model = null
  
  beforeEach ->
    model = new UserMinLengthWithUnless

  it "fails when two chars long and do it is false", ->
    model.do_it = false;
    model.populate({ my_field: "ab" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is too short (minimum is 3 characters)')

  it "passes when two chars long and do it is true", ->
    model.do_it = true;
    model.populate({ my_field: "ab" });
    expect(model.isValid()).toBeTruthy()


#=================================================================================
# maximum
#
# Note: even without allow_blank, nulls and blanks pass since a zero length string 
# is in fact less than the maximum number of characters.
# The typical use case, if you want to enforce at least a 1 token length is to 
# either pair maximum with minimum, or to use a separate "presence" test.
  

theUser = class UserMaxLength extends MVCoffee.Model

theUser.validates 'my_field', test: 'length', maximum: 10

describe "length maximum, default message", ->
  model = null
  
  beforeEach ->
    model = new UserMaxLength

  it "passes when undefined", ->
    expect(model.isValid()).toBeTruthy()

  it "passes when null", ->
    model.populate({ my_field: null });
    expect(model.isValid()).toBeTruthy()

  it "passes when blank", ->
    model.populate({ my_field: "" });
    expect(model.isValid()).toBeTruthy()

  it "passes when one char long", ->
    model.populate({ my_field: "a" });
    expect(model.isValid()).toBeTruthy()

  it "passes when ten chars long", ->
    model.populate({ my_field: "abcdefghij" });
    expect(model.isValid()).toBeTruthy()

  it "fails when eleven chars long", ->
    model.populate({ my_field: "abcdefghijl" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is too long (maximum is 10 characters)')

  it "fails when really long", ->
    model.populate({ my_field: "This is a really long string" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is too long (maximum is 10 characters)')

#----------------------------------------------------------

theUser = class UserMaxLengthWithMessage extends MVCoffee.Model

theUser.validates 'my_field', 
  test: 'length'
  maximum:
    value: 10
    message: "must be at most 10 characters"

describe "length maximum, custom message", ->
  model = null
  
  beforeEach ->
    model = new UserMaxLengthWithMessage


  it "passes when undefined", ->
    expect(model.isValid()).toBeTruthy()

  it "passes when null", ->
    model.populate({ my_field: null });
    expect(model.isValid()).toBeTruthy()

  it "passes when blank", ->
    model.populate({ my_field: "" });
    expect(model.isValid()).toBeTruthy()

  it "passes when one char long", ->
    model.populate({ my_field: "a" });
    expect(model.isValid()).toBeTruthy()

  it "passes when ten chars long", ->
    model.populate({ my_field: "abcdefghij" });
    expect(model.isValid()).toBeTruthy()

  it "fails when eleven chars long", ->
    model.populate({ my_field: "abcdefghijl" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at most 10 characters')

  it "fails when really long", ->
    model.populate({ my_field: "This is a really long string" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at most 10 characters')


#----------------------------------------------------------

theUser = class UserMaxLengthWithTokenizer extends MVCoffee.Model

theUser.validates 'my_field', 
  test: 'length'
  tokenizer: (val) ->
    val.split(/\s+/)
  maximum:
    value: 10
    message: "must be at most 10 words"

describe "length maximum, custom tokenizer", ->
  model = null
  
  beforeEach ->
    model = new UserMaxLengthWithTokenizer

  it "passes when undefined", ->
    expect(model.isValid()).toBeTruthy()

  it "passes when null", ->
    model.populate({ my_field: null });
    expect(model.isValid()).toBeTruthy()

  it "passes when blank", ->
    model.populate({ my_field: "" });
    expect(model.isValid()).toBeTruthy()

  it "passes when one char long", ->
    model.populate({ my_field: "a" });
    expect(model.isValid()).toBeTruthy()

  it "passes when ten chars long", ->
    model.populate({ my_field: "abcdefghij" });
    expect(model.isValid()).toBeTruthy()

  it "passes when eleven chars long", ->
    model.populate({ my_field: "abcdefghijl" });
    expect(model.isValid()).toBeTruthy()

  it "passes when three words long with extra spaces", ->
    model.populate({ my_field: "Three     words   long" });
    expect(model.isValid()).toBeTruthy()

  it "fails when really long", ->
    model.populate({ my_field: "This is a really long string, I mean it is really long!" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at most 10 words')


#----------------------------------------------------------

theUser = class UserMaxLengthOnlyIf extends MVCoffee.Model
  shouldDoIt: ->
    @do_it

theUser.validates 'my_field', 
  test: 'length'
  maximum:
    value: 10
    only_if: "shouldDoIt"

describe "length maximum with only_if", ->
  model = null
  
  beforeEach ->
    model = new UserMaxLengthOnlyIf

  it "fails when eleven chars long and do it is true", ->
    model.do_it = true;
    model.populate({ my_field: "abcdefghijkl" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is too long (maximum is 10 characters)')

  it "passes when eleven chars long and do it is false", ->
    model.do_it = false;
    model.populate({ my_field: "abcdefghijkl" });
    expect(model.isValid()).toBeTruthy()

#----------------------------------------------------------

theUser = class UserMaxLengthUnless extends MVCoffee.Model
  shouldntDoIt: ->
    @do_it

theUser.validates 'my_field', 
  test: 'length'
  maximum:
    value: 10
    unless: "shouldntDoIt"


describe "length maximum with unless", ->
  model = null
  
  beforeEach ->
    model = new UserMaxLengthUnless

  it "fails when eleven chars long and do it is false", ->
    model.do_it = false;
    model.populate({ my_field: "abcdefghijkl" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is too long (maximum is 10 characters)')

  it "passes when eleven chars long and do it is true", ->
    model.do_it = true;
    model.populate({ my_field: "abcdefghijkl" });
    expect(model.isValid()).toBeTruthy()

#=================================================================================
# is

theUser = class UserLengthIs extends MVCoffee.Model

theUser.validates 'my_field', 
  test: 'length', is: 3


describe "length is, default message", ->
  model = null
  
  beforeEach ->
    model = new UserLengthIs

  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is the wrong length (must be 3 characters)')

  it "fails when null", ->
    model.populate({ my_field: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is the wrong length (must be 3 characters)')

  it "fails when blank", ->
    model.populate({ my_field: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is the wrong length (must be 3 characters)')

  it "fails when one char long", ->
    model.populate({ my_field: "a" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is the wrong length (must be 3 characters)')

  it "fails when two chars long", ->
    model.populate({ my_field: "ab" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is the wrong length (must be 3 characters)')

  it "passes when three chars long", ->
    model.populate({ my_field: "abc" });
    expect(model.isValid()).toBeTruthy()

  it "fails when four chars long", ->
    model.populate({ my_field: "abcd" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is the wrong length (must be 3 characters)')

  it "fails when really long", ->
    model.populate({ my_field: "This is a really long string" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is the wrong length (must be 3 characters)')

#----------------------------------------------------------

theUser = class UserLengthIsWithMessage extends MVCoffee.Model

theUser.validates 'my_field', 
  test: 'length'
  is:
    value: 3
    message: "must be exactly 3 characters"

describe "length is, custom message", ->
  model = null
  
  beforeEach ->
    model = new UserLengthIsWithMessage

  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be exactly 3 characters')

  it "fails when null", ->
    model.populate({ my_field: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be exactly 3 characters')

  it "fails when blank", ->
    model.populate({ my_field: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be exactly 3 characters')

  it "fails when one char long", ->
    model.populate({ my_field: "a" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be exactly 3 characters')

  it "fails when two chars long", ->
    model.populate({ my_field: "ab" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be exactly 3 characters')

  it "passes when three chars long", ->
    model.populate({ my_field: "abc" });
    expect(model.isValid()).toBeTruthy()

  it "fails when four chars long", ->
    model.populate({ my_field: "abcd" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be exactly 3 characters')

  it "fails when really long", ->
    model.populate({ my_field: "This is a really long string" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be exactly 3 characters')



#----------------------------------------------------------

theUser = class UserLengthIsWithTokenizer extends MVCoffee.Model

theUser.validates 'my_field', 
  test: 'length'
  tokenizer: (val) ->
    val.split(/\s+/)
  is:
    value: 3
    message: "must be exactly 3 words"

describe "length is, custom tokenizer", ->
  model = null
  
  beforeEach ->
    model = new UserLengthIsWithTokenizer

  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be exactly 3 words')

  it "fails when null", ->
    model.populate({ my_field: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be exactly 3 words')

  it "fails when blank", ->
    model.populate({ my_field: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be exactly 3 words')

  it "fails when one char long", ->
    model.populate({ my_field: "a" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be exactly 3 words')

  it "fails when two chars long", ->
    model.populate({ my_field: "ab" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be exactly 3 words')

  it "fails when three chars long", ->
    model.populate({ my_field: "abc" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be exactly 3 words')

  it "fails when two words long", ->
    model.populate({ my_field: "Two words" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be exactly 3 words')

  it "passes when three words long", ->
    model.populate({ my_field: "Three words long" });
    expect(model.isValid()).toBeTruthy()
    
  it "fails when four words long", ->
    model.populate({ my_field: "Four stinkin' words long" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be exactly 3 words')

  it "passes when three words long with extra spaces", ->
    model.populate({ my_field: "Three     words   long" });
    expect(model.isValid()).toBeTruthy()

  it "fails when really long", ->
    model.populate({ my_field: "This is a really long string, I mean it is really long!" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be exactly 3 words')

#----------------------------------------------------------

theUser = class UserLengthIsOnlyIf extends MVCoffee.Model
  shouldDoIt: ->
    @do_it

theUser.validates 'my_field', 
  test: 'length'
  is:
    value: 3
    only_if: "shouldDoIt"

describe "length is with only_if", ->
  model = null
  
  beforeEach ->
    model = new UserLengthIsOnlyIf

  it "fails when two chars long and do it is true", ->
    model.do_it = true;
    model.populate({ my_field: "ab" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is the wrong length (must be 3 characters)')

  it "passes when two chars long and do it is false", ->
    model.do_it = false;
    model.populate({ my_field: "ab" });
    expect(model.isValid()).toBeTruthy()

#----------------------------------------------------------

theUser = class UserLengthIsUnless extends MVCoffee.Model
  shouldntDoIt: ->
    @do_it

theUser.validates 'my_field', 
  test: 'length'
  is:
    value: 3
    unless: "shouldntDoIt"

describe "length is with unless", ->
  model = null
  
  beforeEach ->
    model = new UserLengthIsUnless

  it "fails when two chars long and do it is false", ->
    model.do_it = false;
    model.populate({ my_field: "ab" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is the wrong length (must be 3 characters)')

  it "passes when two chars long and do it is true", ->
    model.do_it = true;
    model.populate({ my_field: "ab" });
    expect(model.isValid()).toBeTruthy()

#=================================================================================
# range, equivalent to "in" or "within" in rails, but we just use minimum and
# maximum since there isn't a native "range" datatype in javascript.

theUser = class UserLengthRange extends MVCoffee.Model

theUser.validates 'my_field', 
  test: 'length', minimum: 3, maximum: 10

describe "length range, default message", ->
  model = null
  
  beforeEach ->
    model = new UserLengthRange

  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is too short (minimum is 3 characters)')

  it "fails when null", ->
    model.populate({ my_field: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is too short (minimum is 3 characters)')

  it "fails when blank", ->
    model.populate({ my_field: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is too short (minimum is 3 characters)')

  it "fails when one char long", ->
    model.populate({ my_field: "a" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is too short (minimum is 3 characters)')

  it "fails when two chars long", ->
    model.populate({ my_field: "ab" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is too short (minimum is 3 characters)')

  it "passes when three chars long", ->
    model.populate({ my_field: "abc" });
    expect(model.isValid()).toBeTruthy()

  it "passes when seven chars long", ->
    model.populate({ my_field: "abcdefg" });
    expect(model.isValid()).toBeTruthy()

  it "passes when ten chars long", ->
    model.populate({ my_field: "abcdefghij" });
    expect(model.isValid()).toBeTruthy()

  it "fails when eleven chars long", ->
    model.populate({ my_field: "abcdefghijk" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is too long (maximum is 10 characters)')

  it "fails when really long", ->
    model.populate({ my_field: "This is a really long string" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field is too long (maximum is 10 characters)')

#----------------------------------------------------------

theUser = class UserLengthRangeWithMessage extends MVCoffee.Model

theUser.validates 'my_field', 
  test: 'length'
  message: "must be between 3 and 10 characters"
  minimum: 3
  maximum: 10

describe "length range, custom message", ->
  model = null
  
  beforeEach ->
    model = new UserLengthRangeWithMessage

  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be between 3 and 10 characters')

  it "fails when null", ->
    model.populate({ my_field: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be between 3 and 10 characters')

  it "fails when blank", ->
    model.populate({ my_field: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be between 3 and 10 characters')

  it "fails when one char long", ->
    model.populate({ my_field: "a" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be between 3 and 10 characters')

  it "fails when two chars long", ->
    model.populate({ my_field: "ab" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be between 3 and 10 characters')

  it "passes when three chars long", ->
    model.populate({ my_field: "abc" });
    expect(model.isValid()).toBeTruthy()

  it "passes when seven chars long", ->
    model.populate({ my_field: "abcdefg" });
    expect(model.isValid()).toBeTruthy()

  it "passes when ten chars long", ->
    model.populate({ my_field: "abcdefghij" });
    expect(model.isValid()).toBeTruthy()

  it "fails when eleven chars long", ->
    model.populate({ my_field: "abcdefghijk" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be between 3 and 10 characters')

  it "fails when really long", ->
    model.populate({ my_field: "This is a really long string" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be between 3 and 10 characters')


#----------------------------------------------------------

theUser = class UserLengthRangeWithTokenizer extends MVCoffee.Model

theUser.validates 'my_field', 
  test: 'length'
  tokenizer: (val) ->
    val.split(/\s+/)
  minimum:
    value: 3 
    message: "must be at least 3 words"
  maximum:
    value: 10
    message: "must be at most 10 words"


describe "length range, custom tokenizer", ->
  model = null
  
  beforeEach ->
    model = new UserLengthRangeWithTokenizer

  it "fails when undefined", ->
    model.validate();
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at least 3 words')

  it "fails when null", ->
    model.populate({ my_field: null });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at least 3 words')

  it "fails when blank", ->
    model.populate({ my_field: "" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at least 3 words')

  it "fails when one char long", ->
    model.populate({ my_field: "a" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at least 3 words')

  it "fails when two chars long", ->
    model.populate({ my_field: "ab" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at least 3 words')

  it "fails when three chars long", ->
    model.populate({ my_field: "abc" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at least 3 words')

  it "fails when two words long", ->
    model.populate({ my_field: "Two words" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at least 3 words')

  it "passes when three words long", ->
    model.populate({ my_field: "Three words long" });
    expect(model.isValid()).toBeTruthy()
    
  it "passes when three words long with extra spaces", ->
    model.populate({ my_field: "Three     words   long" });
    expect(model.isValid()).toBeTruthy()

  it "passes when 10 words long", ->
    model.populate({ my_field: "One two three four five six seven eight nine ten" });
    expect(model.isValid()).toBeTruthy()
    
  it "fails when really long", ->
    model.populate({ my_field: "This is a really long string, I mean it is really long!" });
    expect(! model.isValid()).toBeTruthy()
    expect(model.errors.length).toEqual(1)
    expect(model.errors[0]).toEqual('My field must be at most 10 words')


