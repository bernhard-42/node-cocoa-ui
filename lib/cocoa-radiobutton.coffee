"use strict"

$ = require "NodObjC"
$.import "AppKit"

{Delegate} = require "./cocoa-delegate"
{createRGBA} = require "./cocoa-utils"
{UiControl} = require "./cocoa-uicontrol"

# The RadioButtons class creates  and wraps them into a coffeescript object
#
# @note It is important to call `init()` at the end to register and properly instantiate the delegate class.
#
# @example
#   choices = [ 'The quick', 'brown fox', 'jumps over', 'the lazy dog']
#   checkbox = new RadioButtons("radio", window, choices)
#   .setState true
#   .onSelect -> debug("#{radiobuttons.getSelected()}:#{choices[radiobuttons.getSelected()]}")
#   .init()
#
class RadioButtons extends UiControl

  # Create a new RadioButtons group being an NSMAtrix of radio NSButtonCells.
  # The Cocoa NSMatrix instance can be accessed via property "nscontrol"
  #
  # @param tag [String] Tag of the RadioButtons instance (each control of a one type must have a different tag)
  # @param parent [Window] The Window instance this button is connect with
  # @param elements [Array<String>] List of labels to add as titles of the button cells
  #
  constructor: (tag, parent, entries) ->
    @type = "radiobuttons"
    
    prototype = $.NSButtonCell("alloc")("init")
    prototype "setButtonType", $.NSRadioButton

    # create space large enough for longest entry
    len = Math.max (e.length for e in entries)...
    prototype "setTitle", $(Array(len).join("X"))

    matrixRect = $.NSMakeRect(0, 0, 12*len, 20*entries.length-2)

    super tag, parent, $.NSMatrix, "RadioButtons", ["initWithFrame", matrixRect,
                                                    "mode", $.NSRadioModeMatrix,
                                                    "prototype", prototype,
                                                    "numberOfRows", entries.length,
                                                    "numberOfColumns", 1]
    cellArray = @nscontrol "cells"
    for i in [0..entries.length-1]
      cellArray("objectAtIndex", i)("setTitle", $(entries[i]))

  # Register/initialize the delgate class the RadioButtons instance
  #
  init: ->
    @nscontrol "setTarget", @delegate.init()
    return @

  # Access the selected element
  #
  # @return [String] The title of the selected radio button
  #
  getSelected: ->
    @nscontrol("selectedRow")

  # Register a callback as action of the RadioButtons instance
  #
  # @param callback [Function] The callback that will be called when a radio button is selected
  #
  # @return [RadioButtons] To allow call chaining
  #
  onSelect: (callback) ->
    @delegate.addMethod "onSelect", "v@:@", callback
    @nscontrol "setAction", "onSelect"
    return @


exports.RadioButtons = RadioButtons
