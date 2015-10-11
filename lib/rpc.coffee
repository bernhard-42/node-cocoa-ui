"use strict"

net = require "net"
q = require "q"
{createDebug} = require("./debug")
{delim, crlf} = require "./rpc-utils"


# Rpc class instantiates an RPC client cto communicate with the Cocoa rpc server CocoaRPC
#
# The RPC connection is used in both directions:
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
#   # Server part
#   rpcServer = new CocoaRpc(app, handler, 5000)
#   .init()
#
#   # Client part
#   rpc = new Rpc(handler, 5000)
#
class Rpc
  debug = createDebug("Rpc", 2)
  msgId = 0

  # Creates an RPC client
  #
  # @param handler [Function] The handler dispatcher for incoming rpc calls
  # @param port [Integer] The port to connet to
  # @param host [String] The host to connect to
  #
  constructor: (@handler, @port=5000, @host="localhost") ->
    @client = new net.Socket()
    @client.setEncoding "utf-8"
    @parked = ""
    @dp = {}

    @client.on "readable",  =>
      while null != (data = @client.read())
        debug "Received (raw):", data
        msgs = (@parked + data).split(delim) # consider previously parked incomplete chunks

        end = msgs.length - 2 # ignore last message. It is empty or incomplete
        last = msgs[end + 1]  # but check for incompleteness
        if last != ""         # the last msg was not completely read
          @parked += last     # move it "back into" the stream

        for msg in msgs[..end]
          debug "- Message:", msg
          jsonMsg = JSON.parse msg
          if jsonMsg.id
            if jsonMsg.id == "_event_"
              debug "received an event", msg
              @handler jsonMsg.request
            else
              id = jsonMsg.id
              delete jsonMsg.id
              @dp[id].resolve({response:jsonMsg.response, status:jsonMsg.status}) # resolve the caller promise
              delete @dp[id]       # and delete the promise object
          else
            throw new Error "Response without id field had to be ignored: #{data}"

  # Connect to the host
  #
  # @return [Promise] This promise will be resolved when the connection was successfully initiated
  #
  connect: ->
    @dp["_connect_"] = q.defer()
    @client.connect @port, @host, ->
      debug "RPC client connected"
    @dp["_connect_"].promise

  # Send an rpc request to the CocoaRPC server
  #
  # @param request [Object] The javascript object describing the request
  #
  # @return [Promise] This promise will be resolved when the RPC response is received
  #
  send: (request) ->
    id = ++msgId
    @dp[id] = q.defer()  # create a separate promise object for each request
    request = crlf({"request":request, "id":id})   # add 'envelope' with identifier
    debug "Send: ", request
    @client.write request
    @dp[id].promise   # return requests promise object


exports.Rpc = Rpc
