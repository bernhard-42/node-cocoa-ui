"use strict"

$ = require "NodObjC"
$.import "AppKit"

{UiText} = require "./cocoa-uicontrol"

# The TextField class creates an editable Cocoa text field and wraps them into a coffeescript object
#
# @example
#   textfield = new TextField("textfield", window, "Some text")
#   .onBeginEditing -> debug "textfield start editing"
#   .onEndEditing -> debug "textfield end editing: #{textfield.getText()}"
#   .init()
#
class TextField extends UiText

  # Create a new editable TextField. The Cocoa NSTextField instance can be accessed via property "nscontrol"
  #
  # @param tag [String] Name or tag of the TextField instance (each control of a one type must have a different tag)
  # @param parent [Window] The Window instance this button is connect with
  # @param text [String] Text to be shown in the text field
  #
  constructor: (tag, parent, text="") ->
    super tag, parent, $.NSTextField, "TextField" # init with delegate
    @type = "textfield"
    @nscontrol "setBezeled", $.NO
    @nscontrol "setBordered", $.NO
    @nscontrol "setDrawsBackground", $.NO
    @nscontrol "setEditable", $.YES
    @nscontrol "setSelectable", $.YES
    @setText text if text

exports.TextField = TextField
