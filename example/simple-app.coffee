"use strict"

{isMaster, createDebug} = require "cocoa-ui"

#
# format time as 00:00:00
#
timeStr = ->
  d = new Date()
  [h, m, s] = [d.getHours(), d.getMinutes(), d.getSeconds()]
  fmt = (i) -> if i<=10 then "0"+i else ""+i
  "#{fmt h}:#{fmt m}:#{fmt s}"

#
# The UI setup
#
createUI = (app) ->
  window = app.addWindow "mainWindow", "Simple App", ["Titled", "Resizable", "Miniaturizable", "Closable"]
  .cascadeTopLeftFromPoint 20, 20

  # define the main view
  view = window.addMainView("mainview").setBackgroundColor(0.5, 0.5, 0.5, 0.4)

  # some UI controls
  clock = window.addLabel("clock", timeStr())
  
  text = "Veniam qui sit aliquip sit fugiat consectetur veniam mollit fugiat eu minim culpa qui."
  inputfield = window.addTextField("input", text).setBackgroundColor(1, 1, 1, 1)
  outputview = window.addTextView("output", "").setBackgroundColor(1, 1, 1, 1).init()
  scrollview = window.addScrollView("scroll", outputview)

  changecase = window.addButton("change", "Upper")
  .onClick ->
    text = inputfield.getText()
    app.fireEvent "toUpper", text   # fire to handle in child
  .init()   # event handler defined, hence init Cocoa delegate

  quit = window.addButton("quit", "Quit")
  .onClick ->
    app.terminate()   # handle in master
  .init()   # event handler defined, hence init Cocoa delegate

  # Add all UI controls to main view ...
  views = [clock, inputfield, scrollview, changecase, quit]
  view.addSubview v for v in views

  metrics = {h1:200, h2:15, h3:20, w1:400, w2:80}   # ... define some metrics ...
  constraints = [                                   # ... and constraints ....
    "H:|-[input(>=w1)]-[clock(w2)]-|"               # (use tags from control definitions and metric keys)
    "H:|-[scroll(>=w1)]-[change(w2)]-|"
    "H:|-[scroll(>=w1)]-[quit(w2)]-|"
    "V:|-[input(>=h1)]-[scroll(>=h1)]-|"
    "V:|-[clock(h2)]"
    "V:[change(h3)]-(4)-[quit(h3)]-|"
  ]
  # ... and layout the UI
  view.setLayout(constraint, metrics, views) for constraint in constraints
  window

#
# Main
#
if isMaster()

  # = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
  # MASTER: Cocoa runloop
  # = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

  debug = createDebug "Master", 5
  debug "Master running"

  App = require("cocoa-ui").App()

  app = new App()
  .onReady ->   # starting point for UI generation in Cocoa runloop
    createUI(@)             # @ bounbd to app instance

  .onStopping ->   # some clean up if necessary
    debug "stopping"
  
  .run()   # Enter Cocoa run loop ...

else

  # = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
  # CHILD: node runloop
  # = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

  debug = createDebug "Child", 5
  debug "Child started"

  {AppProxy} = require("cocoa-ui")
  app = new AppProxy()

  # handle event forwarded from Cocoa master
  .on "toUpper", (text) ->
    attribs = {font:"Lucida Handwriting", size:16, face:"i", color: [0.8,0,0]}
    output = app.window("mainWindow").control("output")
    output.rcall("setText")(text.toUpperCase(), attribs)

  # connect node child with Cocoa master
  .connect ->
    debug "Connected to UI, child running"
    setInterval ->
      d = new Date()
      [h, m, s] = [d.getHours(), d.getMinutes(), d.getSeconds()]
      fmt = (i) -> if i<=10 then "0"+i else ""+i
      clock = app.window("mainWindow").control("clock")
      clock.rcall("setText")(timeStr())
    , 1000
