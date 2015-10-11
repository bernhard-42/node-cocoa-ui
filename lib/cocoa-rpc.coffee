"use strict"

path = require "path"
$ = require "NodObjC"
$.import "./node_modules/cocoa-ui/lib/vendor/AsyncSocketFramework.framework"
{Delegate} = require "./cocoa-delegate"
{nsdata, str, dict, nsdict, cocoaStringify} = require "./cocoa-utils"
{delim, crlf} = require "./rpc-utils"

# Rpc class instantiates an RPC server using the Runloop versio of CocoAsyncSocket Framework (https://github.com/robbiehanson/CocoaAsyncSocket).
# It registers callbacks for Cocoa events fired by CocoAsyncSocket and proveids a generic handler for incoming rpc request
#
# The RPC server is used in both directions:
#
# 1) AppProxy calls rpc methods provided by App. A request from AppProxy will have the envelope `{"request":request, "id":id}`,
# is JSON.stringified and has `\r\n as delimiter. The actual request has the format `{"method":"methodName","params":args}`
#
# The success response has the format `success = <result object from rpc call>` and its envelope is `{"response": success, "status":"ok", "id":id}`
#
# The error response has the format `error = {msg: "eror description"}` and its envelope is `{"response": error, "status":"error", "id":id}`
#
# Responses are also JSON.stringified and have `\r\n` as delimiter
#
# 2) App fires GUI events that will be consumed by AppProxy. A request is of form `{"request":request, "id": "_event_"} with "_event_" being a fixed value
#
# @example
#   rpcServer = new CocoaRpc(app, handler, 5000)
#   .init()
#
class CocoaRpc
  debug = require("./debug").createDebug("Cocoa-Rpc", 2)

  # Creates an RPC server and a delegate for its callbacks
  #
  # @param app [App] The App instance which listens for AppPrxy requests
  # @param handler [Function] The handler dispatcher for incoming rpc calls
  # @param port [Integer] The port to listen on
  #
  constructor: (@app, @handler, @port) ->
    @sock = null
    @delegate = new Delegate "RpcDelegate"
    @delegate.addIvar "connectedSockets", "@"
    .addMethod "onSocket:didAcceptNewSocket:", "v@:@@", (self, sel, sock, newSocket) =>
      debug "Socket accepted"
      @sock = newSocket unless @sock # save the first connected socket as the default socket for sending
      self.ivar("connectedSockets")("addObject", newSocket)

    .addMethod "onSocket:didConnectToHost:port:", "v@:@@i", (self, sel, sock, host, port) ->
      msg = {"response": "Welcome to App Proxy Server", "status": "ok", "id": "_connect_"}
      debug "client connected, send:", crlf(msg)
      sock "writeData", nsdata(crlf msg), "withTimeout", -1, "tag", 0

    .addMethod "onSocket:didWriteDataWithTag:", "v@:@l", (self, sel, sock, tag) ->
      sock "readDataToData", $.AsyncSocket("CRLFData"), "withTimeout", -1, "tag", 0

    .addMethod "onSocket:didReadData:withTag:", "v@:@@l", (self, sel, sock, data, tag) =>
      strData = data("subdataWithRange", $.NSMakeRange(0, data("length") - 2))
      debug "Read data", str(strData)
      try
        response = @handler JSON.parse(str(strData))
      catch e
        console.log e.stack
      sock "writeData", nsdata(crlf response), "withTimeout", -1, "tag", 0

    .addMethod "onSocket:willDisconnectWithError:", "v@:@@", (self, sel, sock, err) ->
      debug err or "Client Disconnected:", sock("connectedHost"), sock("connectedPort")

    .addMethod "onSocketDidDisconnect:", "v@:@", (self, sel, sock) ->
      debug "client disconnected"
      self.ivar("connectedSockets")("removeObject", sock)
    
    .init()

  # Register/initialize the delegate class the CocoaRpc instance, add the RPC Server into the Cocoa
  # Runloop and start listening on the given port
  #
  init: ->
    @delegate.instance.ivar "connectedSockets", $.NSMutableArray("alloc")("init")

    @listenSocket = $.AsyncSocket("alloc")("initWithDelegate", @delegate.instance)
    @listenSocket "setRunLoopModes", $.NSArray("arrayWithObject", $.NSRunLoopCommonModes)
    error = $.alloc("NSError").ref()
    @listenSocket "acceptOnPort", $(@port), "error", error
    debug "Listening", "Port: #{@port}"

  # Fire an event to be consumed by RPC client
  #
  # @param request [Object] The request as described above before the envelope gets added
  #
  send: (request) ->
    msg = {"request":request, "id": "_event_"}
    try
      @sock "writeData", nsdata(crlf msg), "withTimeout", -1, "tag", 0
    catch e
      debug "Warninig", "child does not seem to listen"

  # Use JSON.stringify, but mask all native Cocoa objects as a simple string
  #
  # @param [Object] The object containing Cocoa native classes to be stringified
  #
  # @return [String] The stringified object
  #
  cocoaStringify: (obj) ->
    cocoaStringify obj


exports.CocoaRpc = CocoaRpc
