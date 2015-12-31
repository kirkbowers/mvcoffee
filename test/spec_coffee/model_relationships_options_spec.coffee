MVCoffee = require("../lib/mvcoffee")

theUser = class User extends MVCoffee.Model

theUser.hasMany "activity"
theUser.hasMany "activity", as: "owned_activities", foreignKey: "owner_id"
# Check it with snake case too
theUser.has_many "activity", as: "snake_activities", foreign_key: "owner_id"


theActivity = class Activity extends MVCoffee.Model

theActivity.belongsTo "user"
theActivity.belongsTo "user", as: "owner", foreignKey: "owner_id"
# Check it with snake case too
theActivity.belongs_to "user", as: "snake", foreign_key: "owner_id"

store = new MVCoffee.ModelStore
  user: User
  activity: Activity
  
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
        owner_id: 1
      ,
        id: 2
        name: "Sweep the driveway"
        position: 1
        user_id: 1
        owner_id: 2
      ,
        id: 3
        name: "Wash the cat"
        position: 1
        user_id: 2
        owner_id: 1
      ]
  
describe "model macro methods for relationships with options", ->
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



  it "should define an owned_activities method on User", ->
    user = new User() 
    expect(user.owned_activities instanceof Function).toBeTruthy()

  it "should define an owner method on Activity", ->
    activity = new Activity()
    expect(activity.owner instanceof Function).toBeTruthy()

  it "should not define an owned_activities method on the super class", ->
    model = new MVCoffee.Model
    expect(model.owned_activities).toBeUndefined()

  it "should not define an owner method on the super class", ->
    model = new MVCoffee.Model
    expect(model.owner).toBeUndefined()


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

  it "should find owned_activities for a user", ->
    user = User.find(1)
    acts = user.owned_activities()
    expect(acts instanceof Array).toBeTruthy()
    expect(acts.length).toBe(2)
    expect(acts[0].name).toBe("Rake the yard")
    expect(acts[1].name).toBe("Wash the cat")
    
  it "should find owner for an activity", ->
    activity = Activity.find(2)
    user = activity.owner()
    expect(user instanceof User).toBeTruthy()
    expect(user.id).toBe(2)


  it "should find snake_activities for a user", ->
    user = User.find(1)
    acts = user.snake_activities()
    expect(acts instanceof Array).toBeTruthy()
    expect(acts.length).toBe(2)
    expect(acts[0].name).toBe("Rake the yard")
    expect(acts[1].name).toBe("Wash the cat")
    
  it "should find snaked owner for an activity", ->
    activity = Activity.find(2)
    user = activity.snake()
    expect(user instanceof User).toBeTruthy()
    expect(user.id).toBe(2)
