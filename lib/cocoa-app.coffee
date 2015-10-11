"use strict"

q = require "q"

debug = require("./debug").createDebug("App", 1)

$ = require "NodObjC"

{Delegate} = require "./cocoa-delegate"
{Window} = require "./cocoa-window"
{StatusBar} = require "./cocoa-statusbar"
{CocoaRpc} = require "./cocoa-rpc"
{AppMenu} = require "./cocoa-menu"
{StatusBar} = require "./cocoa-statusbar"
{saveDialog, openDialog} = require "./cocoa-filedialog"
{nsdict, dict, str, nsdata} = require "./cocoa-utils"
{Spawn} = require "./spawn"


# App class is the main Cocoa UI class.
# There is a specific way to import it in order to control when the $.import "AppKit" is started (see example).
# It is important to understand that run() will start the Cocoa runloop and node event loop is ignored afterwards.
# Therefor App creates an RPC server using the Runloop version of CocoaAsyncSocket Framework (https://github.com/robbiehanson/CocoaAsyncSocket).
# AppProxy will communicate with this RPC server
#
# @example
#   App = require("cocoa-ui").App()
#
#   app = new App()
#   .onReady ->
#     createUI()
#   .onStopping ->
#     debug "Stopping"
#   .run()
#
class App

  # Construct a new App
  # @param port [Integer] Port the RPC server will listen to, default = 5000
  #
  constructor: (port=5000) ->
    # child and RPC stuff
    @doNotSerialize = true  # do not stringify for RPC returns
    @rpcServer = new CocoaRpc @, @handler, port
    @rpcServer.init()
    @spawn = new Spawn process.env
    debug "Creating child process"
    @spawn.createChild()

    # UI stuff
    debug "Loading Cocoa"
    $.import "AppKit"

    @pool = $.NSAutoreleasePool("alloc")("init")
    
    key = $("NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints")
    $.NSUserDefaults("standardUserDefaults") "setBool", true, "forKey", key

    @app = $.NSApplication "sharedApplication"
    @app "setActivationPolicy", $.NSApplicationActivationPolicyRegular

    # repository of all defiend windows
    @windows = {}
    
    # The App Delegate
    @delegate = new Delegate "AppDelegate"
    
    return @

  # Start the Cocoa Runloop
  #
  run: ->
    debug "Starting Cocoa runloop"
    delegate = @delegate.init()
    @app "setDelegate", delegate
    # @rpcServer.init()
    @app "activateIgnoringOtherApps", true
    @app "run"

  # Handler for rpc calls
  #
  # @param msg [Object] An object of form {method:"abc", id:42, params:args...}
  #
  # @return [String] JSON.stringified response object of form {"response": error, "status":"ok", "id":id} in success case or in error case {"response": error, "status":"error", "id":id}
  #
  handler: (msg) =>
    request = msg.request
    id = msg.id
    parts = request.method.split("::")
    error = false
    switch
      # Call against App: {"method": "<method>", "params": args}
      when parts.length == 1
        if typeof @[parts[0]] != "function"
          error = {msg: "App does not provide method #{parts[0]}"}
        else
          try
            ret = @[parts[0]](request.params...)
          catch e
            error = e
      # Call against Window: {"method": "<nswindow>::<method>", "params": args}
      when parts.length == 2
        if not @windows[parts[0]]
          error = {msg: "Unknown window \"#{parts[0]}\""}
        else if typeof (@windows[parts[0]])[parts[1]] != "function"
          error = {msg: "Window \"#{parts[0]}\" does not provide method \"#{parts[1]}\""}
        else
          try
            ret = (@windows[parts[0]])[parts[1]](request.params...)
          catch e
            error = e
      # Call against Component: {"method": "<nswindow>::<nscontrol>::<method>", "params": args}
      when parts.length == 3
        if not @windows[parts[0]]
          error = {msg: "Unknown window \"#{parts[0]}\""}
        else if not (@windows[parts[0]]).controls
          error = {msg: "\"#{parts[0]}\" does not seem to be of class 'Window'"}
        else if not (@windows[parts[0]]).controls[parts[1]]
          error = {msg: "\"#{parts[1]}\" is not a control of window \"#{parts[0]}\""}
        else if typeof ((@windows[parts[0]]).controls[parts[1]])[parts[2]] != "function"
          error = {msg: "Control \"#{parts[1]}\" of window \"#{parts[0]}\" does not provide method \"#{parts[2]}\""}
        else
          try
            ret = ((@windows[parts[0]]).controls[parts[1]])[parts[2]](request.params...)
          catch e
            error = e
    if error
      response = {"response": error, "status":"error", "id":id}
    else
      response = {"response": ret, "status":"ok", "id":id}
    return @rpcServer.cocoaStringify(response)
    
  # Add the main menu to the App
  #
  # @param menu [NSMenu] An Cocoa NSMenu instance
  #
  # @return [App] To allow call chaining
  #
  setMainMenu: (menu) ->
    @app "setMainMenu", menu
    return @

  # Add a status bar menu to the App
  # @deprecated
  #
  # @param icon [String] Path to a black and white icon of 18x18 pixel (non retina)
  # @param title [String] Alternative string if icon is not shown
  #
  # @return [App] To allow call chaining
  #
  setStatusBar: (icon, title) ->
    @statusBar = new StatusBar(@, icon, title)
    return @

  # Open the system file open dialog as a separate window (non modal)
  #
  # @example
  #   options =
  #     folder:"/Users/bernhard/Development"
  #     multipleSelection: true
  #     chooseFolders: true
  #     chooseFiles: true
  #     hiddenFiles: true
  #     title: "Test open"
  #     prompt: "Get it"
  #     message: "Select multiple files as you like"
  #
  #   app.openDialog((selection) ->
  #     console.log selection
  #   , options)
  #
  # @param callback [function] The function to be called after file(s) have been selected or dialog has been cancelled
  # @option options [String] folder Starting folder
  # @option options [Boolean] multipleSelection Allow to select more than one file
  # @option options [Boolean] chooseFolders Allow to select folders (instead of opening them)
  # @option options [Boolean] chooseFiles Allow to select files
  # @option options [Boolean] hiddenFiles Show hidden files/folders
  # @option options [String] title Title of the dialog window
  # @option options [String] prompt Prompt shown in the open File Dialog
  # @option options [String] message Message shown in the open File Dialog
  #
  # return [NSOpenPanel] the Cocoa dialog instance
  #
  openDialog: (callback, options={}) ->
    openDialog null, callback, options

  # Open the system file save dialog as a separate window (non modal)
  #
  # @example
  #   options =
  #     folder:"/Users/bernhard/Development"
  #     chooseFiles: true
  #     hiddenFiles: true
  #     title: "Test save"
  #     prompt: "save it"
  #     message: "Save file"
  #
  #   app.saveDialog((selection) ->
  #     console.log selection
  #   , options)
  #
  # @param callback [function] The function to be called after a filename has been selected or dialog has been cancelled
  # @option options [String] folder Starting folder
  # @option options [Boolean] chooseFiles Allow to select files
  # @option options [Boolean] hiddenFiles Show hidden files/folders
  # @option options [String] title Title of the dialog window
  # @option options [String] prompt Prompt shown in the save File Dialog
  # @option options [String] message Message shown in the save File Dialog
  #
  # return [NSSavePanel] the Cocoa dialog instance
  #
  saveDialog: (callback, options={}) ->
    saveDialog null, callback, options

  # Register events to be called from AppProxy via rpc
  #
  # @example
  #   # in App()
  #   app.on "aNewEvent", (params...) ->
  #      doSomething app, params ...
  #
  #   # in AppProxy
  #   appProxy.rcall("aNewEvent")(param1, param2, ...)
  #   .then (result) ->
  #     console.log "callback result", result
  #
  # @param name [String] Name of the event
  # @param callback [Function] Callback function to be called when AppProxy calls the event via rpc
  #
  # @return [App] for success to allow call chaining, else false (breaking the chain)
  #
  on: (name, callback) ->
    # is the name an existing member of the app object?
    if @[name]
      console.log "Error", "Method \"#{name}\" already in use or registered"
      return false
    else
      # no, so just plug it into the app objects
      @[name] = callback
      return @

  # Register a callback for the Cocoa applicationDidFinishLaunching event
  #
  # @param callback [Function] The callback that will be called when Cocoa fires applicationDidFinishLaunching
  #
  # @return [App] To allow call chaining
  #
  onReady: (callback) ->
    @delegate.addMethod "applicationDidFinishLaunching:", "v@:@", =>
      debug "App started"
      # Global error handler to catch errors in Cocoa code
      try
        # @createChild()
        callback.call(@)   # provide app context for handler
      catch error
        console.log error.stack
        process.exit(1)
    return @

  # Register a callback for the Cocoa applicationWillTerminate event (before actually terminating the app)
  #
  # @param callback [Function] The callback that will be called when Cocoa fires applicationWillTerminate
  #
  # @return [App] To allow call chaining
  #
  onStopping: (callback) ->
    @delegate.addMethod "applicationWillTerminate:", "v@:@", =>
      debug "About to stop"
      @stopChild()
      callback.call(@)   # provide app context for handler
    return @

  # fireEvent allows the App to call handlers in the AppProxy.
  # No return, it is fire and forget.
  #
  # @example
  #   # In the AppProxy
  #   appProxy = new AppProxy()
  #   .on "handleOk", (arg) ->
  #     debug "handleOk", arg
  #
  #   # in the App
  #   app.fireEvent "handleOk", {"a":42, b:false}
  #
  # @param event [String] Name of the event
  # @param args... [Array<Object>] Arguments for the rpc call
  #
  fireEvent: (event, args...) ->
    request = {method:event, params:if args then args else []}
    debug "Fire event", JSON.stringify request
    @rpcServer.send request

  # Create the child process
  #
  createChild: ->
    @spawn.createChild()

  # Stop the child process
  #
  stopChild: ->
    @spawn.stopChild()

  # Convenience method to add a window to the App
  #
  # @param tag [String] Tag of window (each window must have a different tag)
  # @param title [String] Window title
  # @param styles [Array<String>] Style Strings can be: "Titled", "Resizable", "Miniaturizable", "Closable"
  # @param width [] Width of window default=0. Usually not used, due to Autolayout support
  # @param height [] Height of window default=0. Usually not used, due to Autolayout support
  #
  # @return [Window] An instance of class Window
  #
  addWindow: (tag, title, styles, width=0, height=0) ->
    return @windows[tag] = new Window @, tag, title, styles, width, height

  # Convenience method to add a window to the App
  #
  # @example
  #   menuConfig =
  #     "AppMenu": [      # name not used
  #         {title: "About", action: "orderFrontStandardAboutPanel", key: ""}
  #         "-"
  #         {title: "Preferences", action: preferences, key: ","}
  #         "-"
  #         {title: "Quit #{name}", action: "terminate", key: "q"}
  #       ]
  #     "File": [
  #         {title:"New",  action:"newDocument", key:"n"}
  #         {title:"Open", action:"openDocument", key:"o"}
  #         "-"
  #         {title:"Close", action:"performClose", key:"w"}
  #         {title:"Save...", action:"saveDocument", key:"s"}
  #         {title:"Save As...", action:"saveDocumentAs", key:""}
  #         "-"
  #         "WithSubMenus": [
  #           {title:"SubMenu 1", action: (-> console.log ("Submenu 1")), key:""}
  #           "FurtherSubMenus": [
  #             {title:"SubMenu 2.1", action: (-> console.log ("Submenu 2.1")), key:""}
  #             {title:"SubMenu 2.2", action: (-> console.log ("Submenu 2.2")), key:""}
  #           ]
  #           {title:"SubMenu 3", action: (-> console.log ("Submenu 3")), key:""}
  #         ]
  #         "-"
  #         {title:"Print...", action:"print", key:""}
  #
  #    menu = app.addAppMenu(menuConfig)
  #    .init()
  #
  # @param menuConfig [Object] Menu definition, see example
  #
  # @return [AppMenu] An instance of class AppMenu
  #
  addAppMenu: (menuConfig) ->
    return new AppMenu(@, menuConfig)

  # Convenience method to add a status bar menu to the App
  #
  # @example
  #   menuConfig =
  #     "StatusMenu": [   # name not used
  #       "WithSubMenus": [
  #         {title:"SubMenu 1", action: (-> console.log ("Status Submenu 1")), key:""}
  #         "FurtherSubMenus": [
  #           {title:"SubMenu 2.1", action: (-> console.log ("Status Submenu 2.1")), key:""}
  #           {title:"SubMenu 2.2", action: (-> console.log ("Status Submenu 2.2")), key:""}
  #         ]
  #         {title:"SubMenu 3", action: (-> console.log ("Status Submenu 3")), key:""}
  #       ]
  #       {title: "Quit #{name}", action: "terminate", key: "q"}
  #     ]
  #   statusBar = app.addStatusBar(imagePath, menuConfig, name)
  #   .init()
  #
  # @param imagePath [String] Path to a black and white icon of 18x18 pixel (non retina)
  # @param menuConfig [Object] Menu definition, see example
  # @param name [String] Alternative string if icon is not shown
  #
  # @return [App] To allow call chaining
  #
  addStatusBar: (imagePath, menuConfig, name) ->
    return new StatusBar(@, imagePath, menuConfig, name)

  # Terminate Cocoa App
  #
  terminate: ->
    @app "terminate", @app

exports.App = App

