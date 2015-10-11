"use strict"

q = require "q"
{Rpc} = require "./rpc"
debug = require("./debug").createDebug("App-Proxy", 1)

# The AppProxy class is the counterpart of the App class.
# It starts an Rpc client and provides methods to
# - register handler for GUI events
# - remote procedure calls to access/modify GUI objects
# - provide methods to access app, window and control methods via rpc
#
# @example
#   {AppProxy} = require("cocoa-ui")
#
#   (app = new AppProxy())
#   .on("event", ->
#     console.log("GUI fire an event")
#   )
#   .connect( ->
#     console.log("Main logic here")
#     app.rcall("guiHandler")(args...))
#
class AppProxy

  # Construct a new AppProxy
  # @param tag [String] A tag for the class hierarchy. Internal use, always call with tag=""
  # @param parent [AppProxy] The parent of the "window" or "control" object. Internal use, always call with parent=null
  # @param port [Integer] The port the App RPC server listens to
  #
  constructor: (@tag="", parent=null, port=5000) ->
    if @tag == ""
      debug("Starting rpc channel")
      @rpc = new Rpc(@handler, port)
      @rpcHandlers = {}
      @app = @
      @type = "app"
    else
      @rpc = parent.rpc
      @rpcHandlers = parent.rpcHandlers
      @app = parent.app

  # Proxy for accessing a Window object of the GUI App. Allows to call remote methods of class Window
  #
  # @example
  #   app.window("SomeWindow").rcall("close")()
  #
  # @param tag [String] Name of the window
  #
  # @return [AppProxy] An object that allows rpc calls to GUI App Window methods
  #
  window: (tag) ->
    throw new Error("window does not follow app") if @tag
    window = new AppProxy("#{tag}", @)
    window.type = "window"
    return window


  # Proxy for accessing a control object of a GUI Window.
  # Allows to call remote methods of objects from (derived) class UiControl, ...
  #
  # @example
  #   app.window("SomeWindow").control("SomeControl").rcall("setEnabled")(false)
  #
  # @param tag [String] Name of the UiControl
  #
  # @return [AppProxy] An object that allows rpc calls to GUI App UiControl methods
  #
  control: (tag) ->
    throw new Error("control without window") unless @tag
    control = new AppProxy("#{@tag}::#{tag}", @)
    control.type = "control"
    return control


  # Connect to RPC server of App class
  #
  # @param callback [Function] Called when RPC handshake is finished
  #
  # @return [AppProxy] To allow call chaining
  #
  connect: (callback) ->
    @rpc.connect()
    .then ->
      try
        callback()
      catch e
        console.log e.stack
    return @

  # Register a callback that gets executed when a GUI control fires this event
  # Allows to react on GUI changes in the AppProxy
  #
  # @param name [String] Name of the event
  # @param callback [Function] Called when RPC handshake is finished
  #
  # @return [AppProxy] To allow call chaining
  #
  on: (name, callback) ->
    @rpcHandlers[name] = callback
    debug("Handler \"#{name}\" registered")
    return @


  # Main handler to dispatch requests of form {method:"abc", params:args...} as abc(args...)
  # for registered handlers (see "on")
  #
  # @param request [Object] An object of form {method:"abc", params:args...}
  #
  # @return [AppProxy] To allow call chaining
  #
  handler: (request) =>
    if @rpcHandlers[request.method]
      debug("Calling #{request.method} with params: ", request.params...)
      @rpcHandlers[request.method].call(@, request.params...)
    else
      debug("Warning", "unknown handler #{request.method} ignored")


  # Call a remote UI method which is either a GUI App method or a registered GUI App handler
  #
  # @param method [String] Name of a remote method/handler
  # @param args... [Array<Object>] Arguments for the rpc call
  #
  # @example
  #   app.window("SomeWindow").control("SomeControl").rcall("setEnabled")(false)
  #
  # @return [Promise] Package "q" based promise that will be resolved when rpc call executed successfully
  #
  rcall: (method) ->
    (args...) =>
      msg = {"method":"#{@tag}#{if @tag then "::" else ""}#{method}","params":args}
      @rpc.send(msg)


  # Consistent error handling that close App process when a severe error happens in AppProxy.
  # Keeps context of "this" and needs to be called for every new subcontext
  #
  # @param func [Function] Function that needs to guarded
  #
  try: (func) ->
    try
      func.call(@)
    catch e
      console.log(e.stack)
      @rcall("terminate")()
      process.exit(1)


exports.AppProxy = AppProxy