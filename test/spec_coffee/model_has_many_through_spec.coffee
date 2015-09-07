MVCoffee = require("../lib/mvcoffee")

theUser = class User extends MVCoffee.Model

theUser.hasMany "item", through: 'user_item'


theItem = class Item extends MVCoffee.Model

theItem.hasMany "user", through: 'user_item'


theUserItem = class UserItem extends MVCoffee.Model

theUserItem.belongsTo "user"
theUserItem.belongsTo "item"


store = new MVCoffee.ModelStore
  user: User
  item: Item
  user_item: UserItem
  
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
    item:
      data: [
        id: 1
        name: "Fork"
      ,
        id: 2
        name: "Spoon"
      ,
        id: 3
        name: "Knife"
      ,
        id: 4
        name: "Spatula"
      ]
    user_item:
      data: [
        id: 1
        user_id: 1
        item_id: 1
      ,
        id: 2
        user_id: 1
        item_id: 3
      ,
        id: 3
        user_id: 2
        item_id: 2
      ,
        id: 4
        user_id: 2
        item_id: 3
      ,
        id: 5
        user_id: 2
        item_id: 4
      ]

describe "model has many through", ->
  it "should define an items method on user", ->
    user = new User() 
    expect(user.items instanceof Function).toBeTruthy()

  it "should define an users method on item", ->
    item = new Item() 
    expect(item.users instanceof Function).toBeTruthy()

  it "should fetch correct items for user Bob", ->
    user = User.find(1)
    items = user.items()
    expect(items.length).toEqual(2)
    expect(items[0].name).toEqual("Fork")
    expect(items[1].name).toEqual("Knife")

  it "should fetch correct items for user Sue", ->
    user = User.find(2)
    items = user.items()
    expect(items.length).toEqual(3)
    expect(items[0].name).toEqual("Spoon")
    expect(items[1].name).toEqual("Knife")
    expect(items[2].name).toEqual("Spatula")

  it "should fetch correct users for item Fork", ->
    item = Item.find(1)
    users = item.users()
    expect(users.length).toEqual(1)
    expect(users[0].name).toEqual("Bob")

  it "should fetch correct users for item Spoon", ->
    item = Item.find(2)
    users = item.users()
    expect(users.length).toEqual(1)
    expect(users[0].name).toEqual("Sue")

  it "should fetch correct users for item Knife", ->
    item = Item.find(3)
    users = item.users()
    expect(users.length).toEqual(2)
    expect(users[0].name).toEqual("Bob")
    expect(users[1].name).toEqual("Sue")

