"use strict"

$ = require "NodObjC"
$.import "AppKit"

{UiText} = require "./cocoa-uicontrol"

# The Checkbox class creates a Cocoa combo box and wraps them into a coffeescript object
#
# @note It is important to call `init()` at the end to register and properly instantiate the delegate class.
#
# @example
#   choices = [ 'The quick', 'brown fox', 'jumps over', 'the lazy dog']
#   combobox = new ComboBox("choices", window, choices)
#   .setEditable true
#   .setText "(select)"
#   .onSelected ->
#     index = combobox.getSelectedIndex()
#     debug "changed: #{index} = #{combobox.getValueAt(index)}"
#   .onBeginEditing -> debug "combobox start editing"
#   .onEndEditing -> debug "combobox end editing: #{combobox.getText()}"
#   .init()
#
class ComboBox extends UiText

  # Create a new ComboBox. The Cocoa NSComboBox instance can be accessed via property "nscontrol"
  #
  # @param tag [String] Tag of the Combobox instance (each control of a one type must have a different tag)
  # @param parent [Window] The Window instance this button is connect with
  # @param elements [Array<String>] List of labels to add as default values to the combo box
  #
  constructor: (tag, parent, elements) ->
    super tag, parent, $.NSComboBox, "ComboBox" # init with delegate
    @type = "combobox"
    @nscontrol "setDrawsBackground", $.NO
    @setElements elements

  # Add elements as selectable values to the combo box
  #
  # @param elements [Array<String>] List of labels to add as default values to the combo box
  #
  # @return [ComboBox] To allow call chaining
  #
  setElements: (elements) ->
    @elements = []
    for element in elements
      @elements.push element
      @nscontrol "addItemWithObjectValue", $(element)
    return @

  # Get the number of elements in the combobox
  #
  # @return [Integer] Number of elements in the chack box
  getLength: ->
    @elements.length

  # Access the element at a given index
  #
  # @param index [Integer] The index of the element to be selected
  #
  # @return [String] The value of the selected element
  #
  getValueAt: (index) ->
    @elements[index]

  # Access the index of the selected element
  #
  # @return [Integer] The index of the selected element
  #
  getSelectedIndex: ->
    @nscontrol "indexOfSelectedItem"

  # Register a callback for the Cocoa comboBoxSelectionDidChange event
  #
  # @param callback [Function] The callback that will be called when Cocoa fires comboBoxSelectionDidChange
  #
  # @return [ComboBox] To allow call chaining
  #
  onSelected: (callback) ->
    @delegate.addMethod "comboBoxSelectionDidChange:", "v@:@", callback
    return @
  

exports.ComboBox = ComboBox
