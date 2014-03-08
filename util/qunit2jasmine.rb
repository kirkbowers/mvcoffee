#!/usr/bin/env ruby

# This is a really quick and dirty utility for porting QUnit tests to jasmine in 
# CoffeeScript.  It gets you _most_ of the way there.  It still requires a bit of 
# hand editing, but very little.
# To protect against overwriting your hand edits, the preferred workflow is:
#
#     mkdir tmp
#     util/qunit2jasmine.rb test/js/some_file_test.js > tmp/some_file_spec.coffee
#     cp -n tmp/some_file_spec.coffee test/spec_coffee/
#
# The -n flag will protect against overwriting your hand edits.  It's also a good idea
# to check into git right the second the tests work.
#
# Author :: Kirk Bowers

lines = File.open(ARGV[0]).readlines

mode = :none
indent = ""

puts <<EOF
MVCoffee = require("../lib/mvcoffee")

theUser = class User extends MVCoffee.Model
EOF

lines.each do |line|
  
  if line =~ /\/\//
    puts line.sub("//", "#")
  
  elsif mode == :none
    if line =~ /^(\s*)module\(\"(.*)\"/
      indent = $1
      desc = $2
      mode = :module
      puts <<EOF
describe "#{desc}", ->
  # TODO!!!
  model = null
  
EOF
    elsif line =~ /^(\s*)test\(\"(.*)\"/
      indent = $1
      desc = $2
      mode = :test
      puts <<EOF
  it "#{desc}", ->
EOF
    else
      puts line
    end
    
  elsif mode == :module
    if line =~ /^#{indent}\}\)/
      mode = :none
    elsif line =~ /^\s*setup/
      puts <<EOF
  beforeEach ->
EOF
    else
      puts line
    end
  elsif mode == :test
    if line =~ /^#{indent}\}\)/
      mode = :none
    elsif line =~ /^\s*ok\s*\((.*)\)\;/
      value = $1
      puts <<EOF
    expect(#{value}).toBeTruthy()
EOF

    elsif line =~ /^\s*equal\s*\((.*),\s*(.*)\)\;/
      value = $1
      expected = $2
      puts <<EOF
    expect(#{value}).toEqual(#{expected})
EOF

    else
      puts line
    end
  end


end


