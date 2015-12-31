class MVCoffee.Pluralizer
  # This had once contained "cactus: cacti", but I took it out because I wanted to test
  # having to add it manually, and really, how often are clients of this framework
  # going to need to have a Model named "Cactus"?
  @irregulars:
    man: "men"
    woman: "women"
    child: "children"
    person: "people"
    mouse: "mice"
    goose: "geese"
    datum: "data"
    alumnus: "alumni"
    hippopotamus: "hippopotami"
    
  @addIrregulars: (words) ->
    for sing, plur of words
      @irregulars[sing] = plur
      
  # Nice alias in case you are only adding one irregular, it reads like english
  @addIrregular: @addIrregulars
  
  @pluralize: (word) ->
    # Get all the words in snake case
    words = word.split("_")
    lastIndex = words.length - 1
    lastWord = words[lastIndex]
    
    result = @irregulars[lastWord]
    if result
      words[lastIndex] = result
      return words.join("_")
    
    len = lastWord.length
    lastLetter = lastWord[len - 1]
    lastTwo = lastWord[(len - 2)..(len - 1)]
    if lastLetter is "s" or lastLetter is "z"
      lastWord += "es"
    else if lastTwo is "ch" or lastTwo is "sh"
      lastWord += "es"
    else if lastLetter is "y"
      lastWord = lastWord.substring(0, len - 1) + "ies"
    else
      lastWord += "s"
      
    words[lastIndex] = lastWord
    words.join("_")  
    