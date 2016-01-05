MVCoffee = require("../lib/mvcoffee")

theDepartment = class Department extends MVCoffee.Model

theDepartment.hasMany "item"
theDepartment.hasMany "item", scope: 'inexpensive'

theItem = class Item extends MVCoffee.Model

theItem.belongsTo "department"


store = new MVCoffee.ModelStore
  department: Department
  item: Item
  
store.load
  mvcoffee_version: "1.0.0"
  models:
    department: 
      data: [
        id: 1
        name: "Toys"
      ,
        id: 2
        name: "Cookware"
      ]
    item: 
      data: [
        id: 1
        name: "Spinning Top"
        price: 1.99
        inexpensive: true
        department_id: 1
      ,
        id: 2
        name: "Video Game Console"
        price: 399.99
        department_id: 1
      ,
        id: 3
        name: "Unicycle"
        price: 459.99
        department_id: 1
      ,
        id: 4
        name: "Juggling Ball"
        price: 9.99
        inexpensive: true
        department_id: 1
      ]
  
describe "model macro methods for relationships with scope", ->
  it "should define an inexpensive_items method on Department", ->
    department = new Department() 
    expect(department.inexpensive_items instanceof Function).toBeTruthy()

  it "should define an items method on Department", ->
    department = new Department() 
    expect(department.items instanceof Function).toBeTruthy()

  it "should find items for a department", ->
    department = Department.find(1)
    items = department.items()
    expect(items instanceof Array).toBeTruthy()
    expect(items.length).toBe(4)
    items = Item.order(items, 'id')
    expect(items[0].name).toBe("Spinning Top")
    expect(items[1].name).toBe("Video Game Console")
    expect(items[2].name).toBe("Unicycle")
    expect(items[3].name).toBe("Juggling Ball")

  it "should find inexpensive_items for a department", ->
    department = Department.find(1)
    items = department.inexpensive_items()
    expect(items instanceof Array).toBeTruthy()
    expect(items.length).toBe(2)
    items = Item.order(items, 'id')
    expect(items[0].name).toBe("Spinning Top")
    expect(items[1].name).toBe("Juggling Ball")




