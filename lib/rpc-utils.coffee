"use strict"

# @property delim The delimiter for RPC messages
#
delim = "\r\n"

# Function JSON.stringify an object and add the delimiter
#
# @param msg [String] JSON.stringified and delimited message
#
crlf = (msg) ->
  if typeof msg == "object"
    JSON.stringify(msg) + delim
  else
    msg + delim


exports.delim = delim
exports.crlf = crlf
