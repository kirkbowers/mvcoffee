MVCoffee = require("../lib/mvcoffee")

theUser = class User extends MVCoffee.Model

theUser.hasMany "activity"
theUser.validates "name", test: "presence"

theActivity = class Activity extends MVCoffee.Model

theActivity.belongsTo "user"


  
describe "using the model save method", ->
  beforeEach ->
    store = new MVCoffee.ModelStore
      user: User
      activity: Activity
  

  it "should save a valid model", ->
    user = new User
      id: 1
      name: "Someone" 
    
    result = user.save()
    expect(result).toBeTruthy()

    users = User.all()
    expect(users.length).toEqual(1)
    expect(users[0].name).toEqual("Someone")

  it "should not save an invalid model", ->
    user = new User
      id: 1
    
    result = user.save()
    expect(result).toBeFalsy()

    users = User.all()
    expect(users.length).toEqual(0)
    
  it "should saveAlways an invalid model anyway", ->
    user = new User
      id: 1
    
    result = user.saveAlways()

    users = User.all()
    expect(users.length).toEqual(1)
    expect(users[0].id).toEqual(1)
    
  it "should save a valid model and find an association", ->
    user = new User
      id: 1
      name: "Someone" 
      
    activity = new Activity
      id: 1
      user_id: 1
      name: "Do something"
    
    user.save()
    activity.save()

    user = User.find(1)
    expect(user.name).toEqual("Someone")
    expect(user.activities().length).toEqual(1)
    expect(user.activities()[0].name).toEqual("Do something")
    
    activity = Activity.find(1)
    expect(activity.name).toEqual("Do something")
    expect(activity.user().name).toEqual("Someone")

