"use strict"

$ = require "NodObjC"
$.import "AppKit"

{UiButton} = require "./cocoa-uicontrol"

# The Checkbox class creates a Cocoa check box and wraps them into a coffeescript object
#
# @note It is important to call `init()` at the end to register and properly instantiate the delegate class.
#
# @example
#   checkbox = new CheckBox("checkColored", window, "colored")
#   .setState true
#   .onClick -> debug "checkbox result=", (checkbox.getState() == 1)
#   .init()
#
class CheckBox extends UiButton

  # Create a new CheckBox. The Cocoa NSButton instance can be accessed via property "nscontrol"
  #
  # @param tag [String] Tag of CheckBox instance (each control of a one type must have a different tag)
  # @param parent [Window] The Window instance this button is connect with
  # @param title [String] The title of the check box
  #
  constructor: (tag, parent, title) ->
    super tag, parent, $.NSButton, "CheckBox" # init with delegate
    @type = "checkbox"
    @nscontrol "setButtonType", $.NSSwitchButton
    @setTitle title

  # Set the check box state to checked or unchecked
  #
  # @param flag [Boolean] If flag==true then the check box will be checked
  #
  # @return [CheckBox] To allow call chaining
  #
  setState: (flag) ->
    @nscontrol "setState", flag
    return @
    
  # Set the check box state to checked or unchecked
  #
  # @return [Boolean] True if box is checked, else false
  #
  getState: ->
    @nscontrol("state")

exports.CheckBox = CheckBox
