"use strict"

$ = require "NodObjC"
$.import "AppKit"

{UiButton} = require "./cocoa-uicontrol"

# The Button class creates a Cocoa button and wraps them into a coffeescript object
#
# @note It is important to call `init()` at the end to register and properly instantiate the delegate class.
#
# @example
#   button = new Button("okButton", window, "OK")
#   .onClick -> console.log "button ok clicked"
#   .init()
#
class Button extends UiButton

  # Create a new Button. The Cocoa NSButton instance can be accessed via property "nscontrol"
  #
  # @param tag [String] Tag of the Button instance (each control of a one type must have a different tag)
  # @param parent [Window] The Window instance this button is connect with
  # @param title [String] The title of the button
  #
  constructor: (tag, parent, title) ->
    super tag, parent, $.NSButton, "Button" # init with delegate
    @type = "button"
    @nscontrol "setButtonType", $.NSMomentaryLightButton
    @nscontrol "setBezelStyle", $.NSRoundedBezelStyle
    @setTitle title


exports.Button = Button
