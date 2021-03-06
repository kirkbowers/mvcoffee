MVCoffee = require("../lib/mvcoffee")

theUser = class User extends MVCoffee.Model

theUser.hasMany "activity"
theUser.hasOne "brain"

theActivity = class Activity extends MVCoffee.Model

theActivity.belongsTo "user"

theBrain = class Brain extends MVCoffee.Model

theBrain.belongsTo "user"

store = new MVCoffee.ModelStore
  user: User
  activity: Activity
  brain: Brain
  
store.load
  mvcoffee_version: "1.0.0"
  models:
    user: 
      data: [
        id: 1
        name: "Bob"
      ,
        id: 2
        name: "Sue"
      ]
    activity: 
      data: [
        id: 1
        name: "Rake the yard"
        position: 2
        user_id: 1
      ,
        id: 2
        name: "Sweep the driveway"
        position: 1
        user_id: 1
      ,
        id: 3
        name: "Wash the cat"
        position: 1
        user_id: 2
      ]
    brain:
      data: [
        id: 1
        name: "gray matter"
        user_id: 1
      ]
  
describe "model macro methods for relationships", ->
  it "should define an activities method on User", ->
    user = new User() 
    expect(user.activities instanceof Function).toBeTruthy()

  it "should define a user method on Activity", ->
    activity = new Activity()
    expect(activity.user instanceof Function).toBeTruthy()

  it "should not define an activities method on the super class", ->
    model = new MVCoffee.Model
    expect(model.activities).toBeUndefined()

  it "should not define a user method on the super class", ->
    model = new MVCoffee.Model
    expect(model.user).toBeUndefined()

  it "should find a model by id", ->
    user = User.find(1)
    expect(user instanceof User).toBeTruthy()
    expect(user.name).toBe("Bob")

  it "should find activities for a user", ->
    user = User.find(1)
    acts = user.activities()
    expect(acts instanceof Array).toBeTruthy()
    expect(acts.length).toBe(2)
    expect(acts[0].name).toBe("Rake the yard")
    expect(acts[1].name).toBe("Sweep the driveway")
    
  it "should find user for an activity", ->
    activity = Activity.find(3)
    user = activity.user()
    expect(user instanceof User).toBeTruthy()
    expect(user.id).toBe(2)

  it "should find a record using findBy", ->
    activity = Activity.findBy
      name: "Wash the cat"
    expect(activity instanceof Activity).toBeTruthy()
    expect(activity.id).toBe(3)
    
  it "should find records using where", ->
    activities = Activity.where
      user_id: 1
    expect(activities.length).toBe(2)
    expect(activities[0].id).toBe(1)
    expect(activities[1].id).toBe(2)
  
  it "should define a brain method on User", ->
    user = new User() 
    expect(user.brain instanceof Function).toBeTruthy()

  it "should define a user method on Brain", ->
    brain = new Brain()
    expect(brain.user instanceof Function).toBeTruthy()

  it "should find a brain for a user", ->
    user = User.find(1)
    brain = user.brain()
    expect(brain instanceof Object).toBeTruthy()
    expect(brain.name).toBe("gray matter")
