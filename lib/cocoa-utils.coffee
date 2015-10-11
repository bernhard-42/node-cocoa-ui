"use strict"

$ = require "NodObjC"
$.import "AppKit"



# Enhance $() to treat boolean correctly
#
# @param value [Object] The object to be converted.
#
# @return [NSObject] The converted object
#
nsconvert = (value) ->
  if typeof value in ["string", "number"]
    $(value)
  else if typeof value == "boolean"
    $.NSNumber "numberWithBool", value
  else
    value

# Log to OS X Console
#
# @param msg [String] The message to log
#
nslog = (msg) ->
  $.NSLog $(msg)

# Create an NSMutableArray from a javascript array of simple type objects
#
# @param array [Array<Object>] Any javascript array of simple types (number, string, boolean)
#
# @return [NSMutableArray] The converted array
#
nsarray = (array) ->
  l = array.length
  nsma = $.NSMutableArray "arrayWithCapacity", l
  for e in array
    nsma "addObject", nsconvert(e)
  nsma

# Create a javascript array from an NSMutableArray
#
# @param nsarray [NSArray] The input Cocoa array
#
# @return [Array<Object>] The converted javascript array
#
array = (nsarray) ->
  (nsarray("objectAtIndex", i) for i in [0..nsarray("count")-1])

# Create an NSMutableDictionary from a one level JSON dict
#
# @param dict [Object] A javascript object with one level only
#
# @return [NSMutableDictionary] The converted Cocoa dictionary
#
nsdict = (dict) ->
  l = Object.keys(dict).length
  keys = $.NSMutableArray "arrayWithCapacity", l
  vals = $.NSMutableArray "arrayWithCapacity", l
  for k,v of dict
    keys "addObject", nsconvert(k)
    vals "addObject", if typeof v in ["object", "function"] then v else nsconvert(v)
  $.NSMutableDictionary "dictionaryWithObjects", vals, "forKeys", keys

# Create a JSON dict from a one level NSMutableDictionary
#
# @param nsdict [NSDictionary] The one level Cocoa dictionary
#
# @return [Object] The converted javascript object
#
dict = (nsdict) ->
  result = {}
  keys = nsdict("allKeys")
  for i in [0..keys("count")-1]
    key = keys("objectAtIndex", i)
    result[key.toString()] = nsdict("objectForKey", key)
  result

# Convert NSData to javascript string
#
# @param nsdata [NSData] The Cocoa data object
#
# @return [String] The converted javascript string
#
str = (nsdata) ->
  $.NSString("alloc")("initWithData", nsdata, "encoding", $.NSUTF8StringEncoding).toString()

# Convert javascript string to NSData
#
# @param str [String] The javascript string to be converted
# @param encoding [String] The string encoding to be used for conversion, default="utf-8"
#
# @return [NSData] The converted Cocoa data object
#
nsdata = (str, encoding="utf-8") ->
  if encoding=="utf-8"
    $(str)("dataUsingEncoding", $.NSUTF8StringEncoding)
  else
    throw new Error "Only utf-8 encoding supprted"

# Create a NSColor from RGB values and alpha
#
# @param r [Float] Value for red between 0 and 1
# @param g [Float] Value for green between 0 and 1
# @param b [Float] Value for blue between 0 and 1
# @param a [Float] Value for alpha between 0 and 1
#
# @return [NSColor] The Cocoa color object
#
createRGBA = (r, g, b, a) ->
  $.NSColor "colorWithCalibratedRed", r, "green", g, "blue", b, "alpha", a

# Create a NSColor from RGB values
#
# @param r [Float] Value for red between 0 and 1
# @param g [Float] Value for green between 0 and 1
# @param b [Float] Value for blue between 0 and 1
#
# @return [NSColor] The Cocoa color object
#
createRGB = (r, g, b) ->
  createRGBA r, g, b, 1.0

# Create an NSAttributedString from a text and attribut options
#
# @example
#   options =
#     font: "Calibri"
#     size: 24
#     color: rgbArray
#     face: "ubi"
#  createAttributedString("Some attributed text", options)
#
# @param text [String] The text to be converted
# @option options [String] font A valid OS X font name
# @option options [Integer] size Font size of the text to be inserted
# @option options [String] face String of characters indicating font face: i=italics, b=bold
# @option options [Array<Float>] color A 3-dimensionla array with values between 0 and 1 encoding an RGB color
#
# @return [NSMutableAttributedString] The converted Cocoa attributed String
#
createAttributedString = (text, options) ->
  attributes = $.NSMutableDictionary("alloc")("init")
  mask = 0
  if options
    if options.font or options.size
      fontName = options.font or "Helvetica"
      fontSize = options.size or 12
      font = $.NSFont "fontWithName",$(fontName), "size", fontSize
      attributes "setObject", font, "forKey", $.NSFontAttributeName # or $("NSFont")
    if options.color
      attributes "setObject", createRGB(options.color...), "forKey", $.NSForegroundColorAttributeName # $("NSColor")
    if "u" in options.face
      attributes "setObject", $(1), "forKey", $.NSUnderlineStyleAttributeName # $("NSUnderline")
    if "i" in options.face
      mask = mask | $.NSItalicFontMask # or 1
    if "b" in options.face
      mask = mask | $.NSBoldFontMask # or 2
  aStr = $.NSMutableAttributedString("alloc")("initWithString", $(text), "attributes", attributes)
  if mask
    aStr "applyFontTraits", mask, "range", $.NSMakeRange(0, aStr("length") - 1)
  return aStr


# Convert JSON objects containing Cocoa objects in a meaningful way.
# - Functions will be replaced with the String <<function>>
# - Cocoa objects will be replaced with the String <<Cocoa object>>
# Everything else will be converted by JSON.stringify
#
# @param obj [Object] The object to convert
#
# @return [String] The converted object as string
#
cocoaStringify = (obj) ->
  if obj is null
    return null
  else if obj.doNotSerialize # CocoObjects derived from UiControl have this setting
    return "<<Cocoa UI Object>>"
  else
    str = JSON.stringify obj, (k,v) ->
      unless v?
        return null
      else if v.doNotSerialize
        return "<<Cocoa Object>>"
      else if typeof v == "function"   # Cocoa objects are functions
        if v.toString()[0..2] == "<NS"
          return v.toString()
        else if v.getClassName?() in ["__NSArrayM", "__NSArray"]
          return array v
        else if v.getClassName?() in ["__NSDictionaryM", "__NSDictionary"]
          return dict v
        else if v.getClassName?() == "__NSCFNumber"
          return v "doubleValue"
        else if v.getClassName?() == "NSTaggedPointerString"
          return v.toString()
        else if v.getClassName?() == "__NSCFBoolean"
          return (v "integerValue") == 1
        else
          return "<<function>>"
      else
        return v
    return str


exports.nslog = nslog
exports.nsarray = nsarray
exports.array = array
exports.nsdict = nsdict
exports.dict = dict
exports.str = str
exports.nsdata = nsdata
exports.createRGBA = createRGBA
exports.createRGB = createRGB
exports.createAttributedString = createAttributedString
exports.cocoaStringify = cocoaStringify
