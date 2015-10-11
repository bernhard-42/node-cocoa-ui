"use strict"

$ = require "NodObjC"
$.import "AppKit"

{UiText} = require "./cocoa-uicontrol"

# The Label class creates a non editable Cocoa label and wraps them into a coffeescript object
#
# @example
#   label = new Label("label", window, "A label")
#
class Label extends UiText

  # Create a new Label. The Cocoa NSTextField instance can be accessed via property "nscontrol"
  #
  # @param tag [String] Name or tag of the Label instance (each control of a one type must have a different tag)
  # @param parent [Window] The Window instance this button is connect with
  # @param text [String] Text to be shown on the label
  #
  constructor: (tag, parent, @text) ->
    super tag, parent, $.NSTextField
    @type = "label"
    @nscontrol "setBezeled", $.NO
    @nscontrol "setDrawsBackground", $.NO
    @nscontrol "setEditable", $.NO
    @nscontrol "setSelectable", $.NO
    @setText @text


exports.Label = Label
