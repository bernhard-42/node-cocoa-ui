"use strict"

$ = require "NodObjC"
$.import "AppKit"

{createRGBA, createAttributedString} = require "./cocoa-utils"
{UiControl, UiText} = require "./cocoa-uicontrol"

# The ScrollView class creates a Cocoa scroll view and wraps them into a coffeescript object
#
# @example
#   textView = new TextView("textview", window)
#   scrollview = new ScrollView("scrollview", window, textview)
#   textview.appendText "Some long text"
#
class ScrollView extends UiControl

  # Create a new ScrollView for a TextView. The Cocoa NSScrollView instance can be accessed via property "nscontrol"
  #
  # @param tag [String] Name or tag of the Scrollview instance (each control of a one type must have a different tag)
  # @param parent [Window] The Window instance this button is connect with
  # @param textview [TextView] The textview to embed into the ScrollView
  # @param hscroll [Boolean] Allow horizontal scrolling
  # @param vscroll [Boolean] Allow vertical scrolling
  #
  constructor: (tag, parent, textView, hscroll=true, vscroll=true) ->
    super tag, parent, $.NSScrollView
    @type = "scrollview"
    @nscontrol "setHasVerticalScroller", if hscroll then $.YES else $.NO
    @nscontrol "setHasHorizontalScroller", if vscroll then $.YES else $.NO
    @nscontrol "setBorderType", $.NSBezelBorder
    @nscontrol "setAutoresizingMask", $.NSViewWidthSizable | $.NSViewHeightSizable
    @nscontrol "setDrawsBackground", $.NO
    # Workaround to get textview correctly sized
    textView.nscontrol "setTranslatesAutoresizingMaskIntoConstraints", true
    @nscontrol "setDocumentView", textView.nscontrol


# The TextView class creates a Cocoa text view and wraps them into a coffeescript object
#
# @note It is important to call `init()` at the end to register and properly instantiate the delegate class.
#
# @example
#   options = {font:"Lucida Handwriting", size:16, face:"i", color: [0.8,0,0]}
#   textView = new TextView("textview", window)
#   .appendText("Some long text", options)
#   .onSelected -> debug textview.selectedRange()
#   .onBeginEditing -> debug "textview start editing"
#   .onEndEditing -> debug "textview end editing: #{textview.getText()}"
#   .init()
#
class TextView extends UiText

  # Create a new TextView. The Cocoa NSTextView instance can be accessed via property "nscontrol"
  # A TextView supports text formatting options, see insertTextAt, insertText, appendText, clearText
  #
  # @param tag [String] Name or tag of the TextVew instance (each control of a one type must have a different tag)
  # @param parent [Window] The Window instance this button is connect with
  #
  constructor: (tag, parent, @width=0, @height=0) ->
    super tag, parent, $.NSTextView, "TextView" # with delegate
    @type = "textview"
    @nscontrol "setEditable", $.YES
    @nscontrol "setVerticallyResizable", $.YES
    @nscontrol "setHorizontallyResizable", $.YES
    @textStorage = @nscontrol "textStorage"

  # Insert text at a specific location
  #
  # @param text [String] The text to be inserted
  # @param index [Integer] The position where the text should be inserted
  # @option options [String] font A valid OS X font name
  # @option options [Integer] size Font size of the text to be inserted
  # @option options [String] face String of characters indicating font face: i=italics, b=bold
  # @option options [Array<Float>] color A 3-dimensionla array with values between 0 and 1 encoding an RGB color
  #
  # @return [TextView] To allow call chaining
  #
  insertTextAt: (text, index=0, options=null) ->
    aStr = createAttributedString text, options
    @textStorage "insertAttributedString", aStr, "atIndex", index
    return @

  # Insert text at a currently selected location
  #
  # @param text [String] The text to be inserted
  # @option options [String] font A valid OS X font name
  # @option options [Integer] size Font size of the text to be inserted
  # @option options [String] face String of characters indicating font face: i=italics, b=bold
  # @option options [Array<Float>] color A 3-dimensionla array with values between 0 and 1 encoding an RGB color
  #
  # @return [TextView] To allow call chaining
  #
  insertText: (text, options=null) ->
    insertionPoint = @selectedRange().location
    @insertTextAt text, insertionPoint, options
    return @

  # Insert text at the beginning
  #
  # @param text [String] The text to be inserted
  # @option options [String] font A valid OS X font name
  # @option options [Integer] size Font size of the text to be inserted
  # @option options [String] face String of characters indicating font face: i=italics, b=bold
  # @option options [Array<Float>] color A 3-dimensionla array with values between 0 and 1 encoding an RGB color
  #
  # @return [TextView] To allow call chaining
  #
  prependText: (text, options=null) ->
    @insertTextAt text, 0, options
    return @

  # Insert text at the end
  #
  # @param text [String] The text to be inserted
  # @option options [String] font A valid OS X font name
  # @option options [Integer] size Font size of the text to be inserted
  # @option options [String] face String of characters indicating font face: i=italics, b=bold
  # @option options [Array<Float>] color A 3-dimensionla array with values between 0 and 1 encoding an RGB color
  # @param follow [Boolean] Scroll to the end of text after appending
  #
  # @return [TextView] To allow call chaining
  #
  appendText: (text, options=null, follow=true) ->
    aStr = createAttributedString text, options
    @textStorage "appendAttributedString", aStr
    if follow
      @nscontrol "scrollRangeToVisible",  $.NSMakeRange(@textStorage("length"), 0)
    return @

  # (Override) Set text of the text view
  #
  # @param text [String] The text to be inserted
  # @option options [String] font A valid OS X font name
  # @option options [Integer] size Font size of the text to be inserted
  # @option options [String] face String of characters indicating font face: i=italics, b=bold, u=underline
  # @option options [Array<Float>] color A 3-dimensionla array with values between 0 and 1 encoding an RGB color
  #
  # @return [TextView] To allow call chaining
  #
  setText: (text, options=null) ->
    @clearText()
    @appendText(text, options)
    return @

  # Clear text view
  #
  # @return [TextView] To allow call chaining
  #
  clearText: ->
    @nscontrol "setString", $("")
    return @

  # (Override) Get text of the text view
  #
  # @return [String] The text of the text view
  #
  getText: ->
    @textStorage "mutableString"
    
  # Get the range of the selected text (start position and length)
  #
  # @return [Integer, Integer] The start position and the length of the selected text as array
  #
  selectedRange: ->
    range = @nscontrol("selectedRanges")("objectAtIndex",0)("rangeValue")
    {location: range.location, length: range.length}

  # Register a callback for the Cocoa textViewDidChangeSelection event
  #
  # @param callback [Function] The callback that will be called when Cocoa fires textViewDidChangeSelection
  #
  # @return [TextView] To allow call chaining
  #
  onSelected: (callback) ->
    @delegate.addMethod "textViewDidChangeSelection:", "v@:@", callback
    return @


exports.TextView = TextView
exports.ScrollView = ScrollView
