"use strict"
debugging = require "debug"

# Create a debug function with a given type and color.
# Debug output will be prefixed with "cocoa-ui:#{prefix}"
#
# @see https://www.npmjs.com/package/debug
#
# @param type [String] Distibuishing type string added to "cocoa-ui:" as a debug output prefix
# @param color [Integer] a number between 1 and 6
#
# @return [Function] The actual debug function
#
createDebug = (type, color) ->
  name = "cocoa-ui:#{type}"
  pad = new Array(Math.max(0, 26-name.length)).join(" ")
  debug = debugging(name + pad)
  debug.color = color
  debug

exports.createDebug = createDebug