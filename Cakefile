fs     = require 'fs'
{exec} = require 'child_process'
sh = require 'execSync'

appFiles = [
  'main'
  'pluralizer'
  'controller_manager'
  'controller'
  'model_store'
  'model'
]

# Thank you to Mike Schilling for (the js equivalent of) this code on stack overflow
copyFile = (source, target, cb) ->
  cbCalled = false

  done = (err) ->
    if (!cbCalled)
      cb(err)
      cbCalled = true

  rd = fs.createReadStream(source)
  rd.on("error", (err) ->
    done(err)
  )
  wr = fs.createWriteStream(target)
  wr.on("error", (err) ->
    done(err)
  )
  wr.on("close", (ex) ->
    done()
  )
  rd.pipe(wr)


# This function doesn't do much but make things a little more readable
# Every step of this Cakefile takes only a second or two to run, so we don't need to
# do true dependency checking like Makefiles do (check time stamps).  If we say one
# task depends on another, we just brute force run it.
depend = (func, callback) ->
  func(callback)

#-----------------------------------------------------------------------------------
# Functions for the tasks to be performed.  Separating them out as functions allows
# them to be called from more than one task as dependencies.  Taking a callback to 
# execute when done allows them to be chained sequentially.

build = (callback) ->
  console.log("Building mvcoffee.js")
  appContents = new Array remaining = appFiles.length
  for file, index in appFiles then do (file, index) ->
    fs.readFile "src/#{file}.js.coffee", 'utf8', (err, fileContents) ->
      throw err if err
      appContents[index] = fileContents
      process() if --remaining is 0
  process = ->
    if not fs.existsSync('lib/')
      fs.mkdirSync 'lib'
    fs.writeFile 'lib/mvcoffee.coffee', appContents.join('\n\n'), 'utf8', (err) ->
      throw err if err
      exec 'coffee --compile lib/mvcoffee.coffee', (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr
        fs.unlink 'lib/mvcoffee.coffee', (err) ->
          throw err if err
          callback() if callback?
          
minify = (callback) ->
  console.log("Minifying mvcoffee.js to mvcoffee.min.js")
  exec 'uglifyjs --output lib/mvcoffee.min.js lib/mvcoffee.js', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr
    callback() if callback?

compile_specs = (callback) ->
  console.log("Compiling jasmine specs written in coffee")
  path = "test/spec_coffee"
  files = fs.readdirSync(path)
  for file in files
    result = file.replace(/\.coffee$/, ".js")
    sh.run "coffee --compile -o test #{path}/#{file}"
  callback() if callback?

test = (callback) ->
  console.log("Compiling test model files")
  exec 'coffee -j models.js -o test/js/coffee test/js/coffee/*.coffee', 
    (err, stdout, stderr) ->
      throw err if err
      console.log stdout + stderr
      
      console.log("Copying mvcoffee.min.js to controller_test project")
      copyFile('lib/mvcoffee.js',
        'test/controller_test/lib/assets/javascripts/mvcoffee.js',
        (err) ->
          throw err if err
      )
      callback() if callback?


#-----------------------------------------------------------------------------------
# The actual task definitions.  Clean and markdown are one-of's so are defined here.
# All others "depend" on functions defined above.

task 'clean', 'Remove all product files for a clean slate', ->
  # Set up a reusable function to remove all files in a directory that match an 
  # optional regexp (sort of mimicking the unix rm with a glob).
  rmdirContents = (dir, filter = /.*/) ->
	# Doing this sync because we want to make sure this finishes before
	# we remove any directories.  Since this is a command line tool, not running
	# on a node server, we don't have to be so node-ish and incur the coding 
	# overhead of counting completed async jobs...
    files = fs.readdirSync dir
    for file in files when filter.test(file)
      fs.unlinkSync "#{dir}/#{file}"
     
  # This also is not very node-like.  Good enough for a command-line tool.  
  console.log("Removing lib dir")   
  if fs.existsSync('lib/')
    rmdirContents "lib"
    fs.rmdir "lib", (err) ->
      throw err if err

  # Delete only the files that end in .js, NOT the .coffee files
  console.log("Removing compiled test models")
  rmdirContents "test/js/coffee/", /\.js$/

  # Delete lib files from controller test
  console.log("Removing lib files from controller_test")
  rmdirContents "test/controller_test/lib/assets/javascripts/", /\.js$/
  
  # Delete the html files in the root directory, NOT the files in test
  # Those in this directory are produced by "compiling" the markdown files into html
  console.log("Removing html compiled from markdowns")
  rmdirContents "./", /\.html$/

task 'build', 'Build project from src/*.coffee to lib/*.js', ->
  depend build

task 'minify', 'Build and minify lib/mvcoffee.js to lib/mvcoffee.min.js', ->
  depend build, minify


task 'test-build', 'Build project and compile the coffee files needed to run the QUnit tests', ->
  depend build, ->
    depend minify, test
    
task 'spec-build', 'Build the jasmine specs written in coffeescript and run them', ->
  depend build, compile_specs
  
task 'spec', 'Run the jasmine specs', ->
  depend build, ->
    depend compile_specs, ->
      sh.run "jasmine-node test"

  
task 'all', 'Build project, minify and compile files needed to run QUnity tests', ->
  depend build, ->
    depend minify, test

task 'markdown', 'Compile any markdown documentation files into html', ->
  console.log("Compiling markdowns into html")
  fs.readdir "./", (err, files) ->
    throw err if err
    for file in files when /\.md$/.test(file)
      fileRoot = file.substring(0, file.length - 3)
      exec "Markdown.pl #{file} > #{fileRoot}.html", (err, stdout, stderr) ->
        # Since we're redirecting the output in the exec command, I'm assuming
        # stdout contains nothing.
        throw err if err
        console.log stderr
