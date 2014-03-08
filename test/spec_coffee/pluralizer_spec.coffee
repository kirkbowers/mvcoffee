MVCoffee = require("../lib/mvcoffee")

describe "Pluralizer out of the box", ->

  it "adds s to a non-irregular regular-ending", ->
    result = MVCoffee.Pluralizer.pluralize("cook")
    expect(result).toBe("cooks")
    
  it "adds s to a non-irregular regular-ending compound word snake case", ->
    result = MVCoffee.Pluralizer.pluralize("too_many_cook")
    expect(result).toBe("too_many_cooks")
    
  it "adds es to a non-irregular s-ending", ->
    result = MVCoffee.Pluralizer.pluralize("boss")
    expect(result).toBe("bosses")
    
  it "adds es to a non-irregular s-ending", ->
    result = MVCoffee.Pluralizer.pluralize("boss")
    expect(result).toBe("bosses")
    
  it "adds es to a non-irregular z-ending", ->
    result = MVCoffee.Pluralizer.pluralize("buzz")
    expect(result).toBe("buzzes")
    
  it "adds es to a non-irregular ch-ending", ->
    result = MVCoffee.Pluralizer.pluralize("catch")
    expect(result).toBe("catches")
    
  it "adds es to a non-irregular sh-ending", ->
    result = MVCoffee.Pluralizer.pluralize("flush")
    expect(result).toBe("flushes")
    
  it "replaces y with ies", ->
    result = MVCoffee.Pluralizer.pluralize("fairy")
    expect(result).toBe("fairies")
    
  it "replaces with an irregular plural when one word snake case", ->
    result = MVCoffee.Pluralizer.pluralize("cactus")
    expect(result).toBe("cacti")

  it "replaces with an irregular plural when several words snake case", ->
    result = MVCoffee.Pluralizer.pluralize("big_ass_mouse")
    expect(result).toBe("big_ass_mice")

describe "Pluralizer with one irregular added", ->
  beforeEach ->
    MVCoffee.Pluralizer.addIrregular
      knife: "knives"
      
  it "still adds s to a non-irregular", ->
    result = MVCoffee.Pluralizer.pluralize("spoon")
    expect(result).toBe("spoons")
  
  it "still handles old irregulars", ->
    result = MVCoffee.Pluralizer.pluralize("child")
    expect(result).toBe("children")
  
  it "handles new irregular", ->
    result = MVCoffee.Pluralizer.pluralize("knife")
    expect(result).toBe("knives")
  
describe "Pluralizer with a few irregulars added", ->
  beforeEach ->
    MVCoffee.Pluralizer.addIrregulars
      moose: "moose"
      life: "lives"
      surrealist: "fishes"
      
  it "still adds s to a non-irregular", ->
    result = MVCoffee.Pluralizer.pluralize("bear")
    expect(result).toBe("bears")
  
  it "still handles old irregulars", ->
    result = MVCoffee.Pluralizer.pluralize("hippopotamus")
    expect(result).toBe("hippopotami")
  
  it "handles new irregulars", ->
    result = MVCoffee.Pluralizer.pluralize("moose")
    expect(result).toBe("moose")
    result = MVCoffee.Pluralizer.pluralize("life")
    expect(result).toBe("lives")
    result = MVCoffee.Pluralizer.pluralize("surrealist")
    expect(result).toBe("fishes")
  
  it "handles compound words with new irregulars", ->
    result = MVCoffee.Pluralizer.pluralize("half_life")
    expect(result).toBe("half_lives")
