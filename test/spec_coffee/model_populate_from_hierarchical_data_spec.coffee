MVCoffee = require("../lib/mvcoffee")

theUser = class User extends MVCoffee.Model

theUser.hasMany "activity", order: "position"
theUser.hasOne "brain"

theActivity = class Activity extends MVCoffee.Model

theActivity.belongsTo "user"
theActivity.hasMany "subactivity"


theSubActivity = class Subactivity extends MVCoffee.Model

theSubActivity.belongsTo "activity"



theBrain = class Brain extends MVCoffee.Model

theBrain.belongsTo "user"


store = new MVCoffee.ModelStore
  user: User
  activity: Activity
  subactivity: Subactivity
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
        activity: [
          id: 1
          user_id: 2
          name: "Rake the yard"
        ,
          id: 2
          user_id: 2
          name: "Make a sandwich"
          subactivity: [
            id: 1
            activity_id: 2
            name: "Spread peanut butter"
          ,
            id: 2
            activity_id: 2
            name: "Spread jelly"
          ]
        ]
      ,
        id: 3
        name: "Danny"
        brain: [
          id: 1
          user_id: 3
          name: "gray matter"
        ]
      ]
      
describe "models with hierarchical data", ->
  it "should find a model that has no has many things", ->
    user = User.find(1)
    expect(user.name).toBe("Bob")
    expect(user.activities().length).toBe(0)
    expect(user.brain()).toBeFalsy()
    
  it "should find a model that has many things", ->
    user = User.find(2)
    expect(user.name).toBe("Sue")
    expect(Activity.all().length).toBe(2)
    expect(Subactivity.all().length).toBe(2)
    activities = user.activities()
    expect(activities.length).toBe(2)
    expect(activities[0].name).toBe("Rake the yard")
    expect(activities[1].name).toBe("Make a sandwich")
    expect(activities[0].subactivities().length).toBe(0)
    subs = activities[1].subactivities()
    expect(subs.length).toBe(2)
    expect(subs[0].name).toBe("Spread peanut butter")
    expect(subs[1].name).toBe("Spread jelly")
    expect(user.brain()).toBeFalsy()

  it "should find a model that has one thing", ->
    user = User.find(3)
    expect(user.name).toBe("Danny")
    expect(user.activities().length).toBe(0)
    expect(user.brain().name).toEqual("gray matter")
    

