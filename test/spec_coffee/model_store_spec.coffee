MVCoffee = require("../lib/mvcoffee")

# I for one, am not a big fan of mock objects.  
# I'm much more concerned that Models and the ModelStore interact correctly.
# One of the big things that matters is that when the ModelStore instantiates a Model
# from a vanilla object, the Model assumes the properties of that object.
# We have to do a bit of fenagling here to make this mock object do the right thing.
# So what really are we testing?  That the mock object does the right thing, which has
# no bearing on the use of this framework in the wild?  Or that the framework really
# works?  I fear there is a risk of a rusty bridge here, but this is the "right" way
# to do things...
class MockModel
  constructor: (values = {}) ->
    for key, val of values
      @[key] = val

class MockWithName
  modelName: "something_irregular"
  modelNamePlural: "somethings_irregular"

describe "ModelStore initialization and loading", ->
  # This makes sure store is declared in this scope
  store = null
  
  beforeEach ->
    store = new MVCoffee.ModelStore
      mock_model: MockModel
      mock_with_name: MockWithName
      
  it "sets the modelName on an added model", ->
    model = new MockModel()
    expect(model.modelName).toBe("mock_model")
    
  it "sets the modelNamePlural on an added model", ->
    model = new MockModel()
    expect(model.modelNamePlural).toBe("mock_models")
    
  it "sets the reference back to the model store on an added model", ->
    model = new MockModel()
    expect(model.modelStore).toEqual(store)
    
  it "doesn't override the modelName on an added model with a static name", ->
    model = new MockWithName()
    expect(model.modelName).toBe("something_irregular")
    
  it "doesn't override the modelNamePlural on an added model with a static name", ->
    model = new MockWithName()
    expect(model.modelNamePlural).toBe("somethings_irregular")
    
  it "passes unrecognized properties through unmodified", ->
    data = { foo: 3 }
    result = store.load data
    expect(result).toEqual(data)

  it "merges unrecognized properties with defaults supplied", ->
    data = { foo: 3 }
    defaults = { blah: 4 }
    result = store.load data, defaults
    expect(result).toEqual({ foo: 3, blah: 4 })

  it "overwrites matching default properties", ->
    data = { foo: "changed" }
    defaults = { foo: "original" }
    result = store.load data, defaults
    expect(result).toEqual(data)

  it "converts recognized property as an object to a model", ->
    data =
      mock_model:
        id: 1
        name: "The First"
    result = store.load data
    expect(result.mock_model instanceof MockModel).toBe(true)
    expect(result.mock_model.id).toBe(1)
    expect(result.mock_model.name).toBe("The First")
      
  it "converts recognized property as an array to an array of models", ->
    data =
      mock_model: [
        id: 1
        name: "The First"
      ,
        id: 2
        name: "What's on second"
      ]
      
    result = store.load data
    expect(result.mock_model instanceof Array).toBe(true)
    expect(result.mock_model.length).toBe(2)
    expect(result.mock_model[0] instanceof MockModel).toBe(true)
    expect(result.mock_model[1] instanceof MockModel).toBe(true)
    expect(result.mock_model[0].id).toBe(1)
    expect(result.mock_model[0].name).toBe("The First")
    expect(result.mock_model[1].id).toBe(2)
    expect(result.mock_model[1].name).toBe("What's on second")
    
describe "ModelStore loading records and querying", ->
  store = null
  mocks = null

  beforeEach ->
    store = new MVCoffee.ModelStore
      mock_model: MockModel
      
    data =
      mock_model: [
        id: 1
        name: "One"
        foreign_id: 11
      ,
        id: 2
        name: "Two"
        foreign_id: 11
      ,
        id: 3
        name: "Three"
        foreign_id: 42
      ]

    result = store.load data
    mocks = result.mock_model
      
  it "finds by id", ->
    result = store.find("mock_model", 2)
    expect(result instanceof MockModel).toBeTruthy()
    expect(result.id).toBe(2)
    expect(result).toEqual(mocks[1])
    
  it "returns undefined on find of a nonexistent id", ->
    result = store.find("mock_model", 4)
    expect(result).toBeUndefined()

  it "finds by one arbitrary field", ->
    result = store.findBy("mock_model", name: "Two")
    expect(result instanceof MockModel).toBeTruthy()
    expect(result.id).toBe(2)
    expect(result).toEqual(mocks[1])

  it "finds by two arbitrary fields", ->
    result = store.findBy("mock_model", name: "Two", foreign_id: 11)
    expect(result instanceof MockModel).toBeTruthy()
    expect(result.id).toBe(2)
    expect(result).toEqual(mocks[1])

  it "returns null on find of a non-matching condition", ->
    result = store.findBy("mock_model", name: "Four")
    expect(result).toBeNull()

  it "finds only one by one arbitrary field when more than one match exists", ->
    result = store.findBy("mock_model", foreign_id: 11)
    expect(result instanceof MockModel).toBeTruthy()
    expect(result.id).toBe(1)
    expect(result).toEqual(mocks[0])

  it "finds an array of one object when there is one match on where", ->
    result = store.where("mock_model", foreign_id: 42)
    expect(result instanceof Array).toBeTruthy()
    expect(result.length).toBe(1)
    expect(result[0] instanceof MockModel).toBeTruthy()
    expect(result[0].id).toBe(3)

  it "finds an array of several objects when there is more than one match on where", ->
    result = store.where("mock_model", foreign_id: 11)
    expect(result instanceof Array).toBeTruthy()
    expect(result.length).toBe(2)
    expect(result[0] instanceof MockModel).toBeTruthy()
    expect(result[0].id).toBe(1)
    expect(result[1] instanceof MockModel).toBeTruthy()
    expect(result[1].id).toBe(2)

  it "finds an array of zero objects when there is no match on where", ->
    result = store.where("mock_model", foreign_id: 96)
    expect(result instanceof Array).toBeTruthy()
    expect(result.length).toBe(0)

  it "finds an array of all instances with all", ->
    result = store.all("mock_model")
    expect(result instanceof Array).toBeTruthy()
    expect(result.length).toBe(3)
    expect(result[0] instanceof MockModel).toBeTruthy()
    expect(result[0].id).toBe(1)
    expect(result[1] instanceof MockModel).toBeTruthy()
    expect(result[1].id).toBe(2)
    expect(result[2] instanceof MockModel).toBeTruthy()
    expect(result[2].id).toBe(3)
    