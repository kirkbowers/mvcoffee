# How to test MVCoffee

The functionality of MVCoffee ranges from easy-to-automatically-test 
utilities to hard-to-test capabilities that depend entirely on user interaction.
In order to test the full range, the tests are broken into three parts: straight unit
tests, unit tests that depend on the contents of an html form, and "gray box" tests
that depend on user interaction.  Model validations can be tested traditionally,
model population (may) depend on user input, and controller activation and refreshing
depends entirely on live user actions.

Before you run any of the tests described below, the library must be built, and any
supporting test files in CoffeeScript must be compiled to JavaScript.  In order to 
carry out both steps, from the project root directory run:

    cake test

In addition to the tests described above, there is a simple little sanity check in the
test directory to see if the library will load as a node module with proper namespacing.
To run this test, you must have [nodeunit](https://github.com/caolan/nodeunit) installed
and type either:

    nodeunit node_test.js
    
or on a unix system, simply:

    ./node_test.js
    

## Model validation tests

Model validation tests are the simplest because they operate on values already in 
memory with no concern for the source.  They are straight QUnit tests that are run 
by visiting the page `test/validations.html` in any web browser.  

## Model population tests

Models can be populated in full by two methods:  passing in an object to the 
constructor, or calling `populate()` while there is a corresponding input form on the
current html page.  The former may be tested by straight unit tests.  The latter 
requires an html page with an input form to truly test accurately.  You can run these
tests by visiting the page `test/population.html` in any web browser.  There is a form
on that page that is prepopulated with values the tests expect to see.  All the form
inputs are disabled to protect against false negatives caused by inadvertent modification
of the form data.
    
## Controller tests

Controller behavior in MVCoffee depends on user interactivity.  There are things it 
should do when a user first lands on a web page, sits on that page for some length of
time, changes windows or tabs, or visits a different page within the application.  
This kind of interactivity is difficult if not impossible to test automatically.  
Some of it may be simulated by some degree of convoluted and contrived mocking, but all 
that may prove is "selling oneself a rusty bridge", passing the tests but not being truly
representative of actual browser behavior in the wild.  Much as we all prefer automated 
tests, some times you have to suck it up and black box test things (that is, fire it up
and run through it from the end customer's perspective).  In the case of MVCoffee's
controllers, we can do what I call "gray box testing", using reusable, pre-programmed
test cases that set up initial conditions that then must be manually interacted with
and visually verified.

In order to test the controller behavior of MVCoffee, there is a very simple Rails 
project included in the `test` directory called `controller_test`.  Change to that
directory and run `rails server` then point your browser to `localhost:3000` (you may
have to run `bundle install` first).

What you'll see is a page with the page header "Default Timer" and four sub-headings:
"Default Timer", "Override Timer", "No Timer" and "No Refresh".  These correspond to
the four different scenarios of controller behavior.  You can visit any of the four
different tests by clicking on the subject heading.  Each test gives a description
at the top of the page of what you should see as you interact with the page.  When you
start any given test, you should see a list item under that test's heading that that
controller has started.  You may see other list items accumulate as time passes and/or
you perform other actions.  You should never see messages appear under any of the three
headings for the controllers other than the currently active one.

### Default Timer

The Default Timer controller provides a refresh callback that adds a list item under
the "Default Timer" heading with the current timestamp.  It does not override the 
default refresh interval of 60 seconds, so as you sit on the page, the refresh messages
should appear exactly one minute apart.  If you cause the window to lose focus by 
switching to another window or tab, no refreshes should occur while you are away, and a 
refresh should occur immediately when you return to that window.  Leaving the window and
returning should restart the timer so the next refresh is 60 seconds after focus was
returned.

### Override Timer

The Override Timer controller provides a refresh callback that adds a list item under
the "Override Timer" heading with the current timestamp.  It overrides the 
default refresh interval with a rate of 5 seconds, so as you sit on the page, the 
refresh messages should appear 5 seconds apart.  If you cause the window to lose focus by 
switching to another window or tab, no refreshes should occur while you are away, and a 
refresh should occur immediately when you return to that window.  Leaving the window and
returning should restart the timer so the next refresh is 5 seconds after focus was
returned.

### No Timer

The No Timer controller provides a refresh callback that adds a list item under
the "No Timer" heading with the current timestamp.  It overrides the 
default refresh interval with a value of zero.  This should disable the timer, so as you
sit on the page, refresh messages should never appear.  If you cause the window to lose
focus by switching to another window or tab, no refreshes should occur while you are away, 
and a  refresh should occur immediately when you return to that window.  Leaving the 
window and returning should not start a timer, so the refresh that occurred when focus 
was regained should be the last refresh message no matter how long you sit there.

### No Refresh

The No Refresh controller does not provide a refresh method.  This should disable all
refreshing, so as you sit on the page, refresh messages should never appear.  If you cause
the window to lose focus by switching to another window or tab, no refreshes should occur
while you are away, and no refresh should occur when you return to that window.  Leaving
the window and returning should not start a timer, so no refresh messages should appear
no matter how long you sit there.


