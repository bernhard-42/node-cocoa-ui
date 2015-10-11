"use strict"

{isMaster, createDebug} = require "cocoa-ui"

if isMaster()

  # = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
  # MASTER: Cocoa runloop
  # = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

  debug = createDebug "Master", 5
  debug "Master running"

  App = require("cocoa-ui").App()
  {createUI, createDefaultMenu, createStatusBar} = require "./ui"

  app = new App()

  .onReady ->
    appMenu = createDefaultMenu("Test", @)
    window = createUI("Test", @)
    statusMenu = createStatusBar("Test", "/Users/bernhard/Development/cocoa-ui/example/NodeCocoaStatus.png", @)

  .onStopping ->
    debug "Stopping"
    
  .on "childReady", ->
    debug "Child started"

  .run()

  # Cocoa run loop - node will never reach here ...


# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# CHILD: node runloop
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

else

  {AppProxy} = require("cocoa-ui")

  debug = createDebug "Child", 5
  debug "Child running"

  app = new AppProxy()

  .on "handleOk", (arg) ->
    debug "handleOk", arg
    
  .on "handleCancel", (arg) ->
    debug "handleCancel", arg

  .on "manageProgress", (progressInd, button) ->
    app.try ->   # catch errors and stop both master and child
      [min, max] = [0, 10]
      app.rcall("progressWindow")("Progress", min, max)   # open progress window
      .then (result) ->
        if result.status == "ok"
          app.try ->   # catch errors and stop both master and child
            button2 = app.window(button.window).control(button.control)
            button2.rcall("setEnabled")(false)
            .then (result) ->
              debug "Disable button:", result
              counter = setInterval ->
                app.try ->
                  progress = app.window(progressInd.window).control(progressInd.control)
                  if min++ < max
                    progress.rcall("increment")(1)
                    .then (result) -> debug "Increment progress", result
                  else
                    clearInterval(counter)
                    app.window(progressInd.window).rcall("close")()
                    .then (result) -> debug "Close progress window:", result
                    button2.rcall("setEnabled")(true)
                    .then (result) -> debug "Enable button:", result
              , 250

  .connect ->
    app.try ->   # catch errors and stop both master and child
      debug "connect"
      app.rcall("childReady")()
      .then (result) -> debug "call 1", result

      window = app.window("mainWindow")
      window.control("label").rcall("setText")("Changed")
      .then (result) -> debug "call 2", result

      window.control("checkbox2").rcall("setState")(true)
      .then (result) -> debug "call 3", result

      window.control("textfield").rcall("setText")("Awesome")
      .then (result) -> debug "call 4", result
