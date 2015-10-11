"use strict"

$ = require "NodObjC"
$.import "AppKit"

{Delegate} = require "./cocoa-delegate"
{createRGBA} = require "./cocoa-utils"

# The UiControl class is the base class for all Cocoa controls. 
# It creates the actual Cocoa instance for the control and a delegate class if requested.
#
# The delegate class willbe named "#{delegateName}_#{tag}", so ech control using the same delegateName needs to have a different tag.
# The delegate class will be instantiated by UiButton or UiText which inherit from UiControl via their init method.
#
# If UiControl is used directly, an init method needs to be defined that calls @delegate.init()
#
class UiControl

  # Create a new UiControl instance.
  #
  # @param tag [String] Tag of the UiControl instance (each control for one delegateName must have a different tag)
  # @param parent [Window] The Window instance this button is connect with
  # @param UiClass [String] The name of the Cocoac control calls to instantiate
  # @param delegateName [String] Name of delegate to be created. If missing, no delegate gets created
  # @param init [Array<String>] An array of Cocoa selectors and parameters.
  #
  constructor: (@tag, @parent, UiClass, delegateName=null, init=["init"]) ->
    @nscontrol = UiClass("alloc")(init...)
    @nscontrol "setTranslatesAutoresizingMaskIntoConstraints", false
    @delegate = if delegateName then new Delegate("#{delegateName}_#{@tag}") else null
    @doNotSerialize = true   # do not stringify for RPC returns
    return @

  # Set the background color for an UiControl
  #
  # @param r [Float] Value for red between 0 and 1
  # @param g [Float] Value for green between 0 and 1
  # @param b [Float] Value for blue between 0 and 1
  # @param a [Float] Value for alpha between 0 and 1, default is 1
  #
  # @return [UiControl] To allow call chaining
  #
  setBackgroundColor: (r, g, b, a=1) ->
    if @nscontrol.getClassName().toString() != "NSTextView"
      @nscontrol "setWantsLayer", true
      @nscontrol("layer") "setBackgroundColor", $.CGColorCreateGenericRGB(r,g,b,a)
    else
      @nscontrol "setBackgroundColor", createRGBA(r, g, b, a)
    return @

  # Set the background color for an UiControl
  #
  # @param flag [Boolean] Set the UiControl instance to enabled (true) or disabled (false)
  #
  # @return [UiControl] To allow call chaining
  #
  setEnabled: (flag) ->
    @nscontrol "setEnabled", flag
    return @


# The UiButton class inherits from UiControl and models all Cocoa Control that behave similar to NSButton
#
class UiButton extends UiControl

  # Create a UiButton instance
  #
  # @param tag [String] Tag of the UiControl instance (each control for one delegateName must have a different tag)
  # @param parent [Window] The Window instance this button is connect with
  # @param UiClass [String] The name of the Cocoac control calls to instantiate
  # @param delegateName [String] Name of delegate to be created. If missing, no delegate gets created
  # @param init [Array<String>] An array of Cocoa selectors and parameters.
  #
  constructor: (tag, parent, UiClass, delegateName=null, init=["init"]) ->
    super tag, parent, UiClass, delegateName, init

  # Register/initialize the delgate class the UiButton instance
  #
  init: ->
    if @delegate
      @nscontrol "setTarget", @delegate.init()
    return @

  # Set title of a UiButton
  #
  # @param title [String] The title to be set
  #
  # @return [UiButton] To allow call chaining
  #
  setTitle: (title) ->
    @nscontrol "setTitle", $(title)
    return @

  # Register a callback when the button is clicked
  #
  # @param callback [Function] The callback that will be called when the button is clicked
  #
  # @return [UiButton] To allow call chaining
  #
  onClick: (callback) ->
    @delegate.addMethod "onClick", "v@:@", callback
    @nscontrol "setAction", "onClick"
    return @


# The UiText class inherits from UiControl and models all Cocoa Control that behave similar to NSTextView or NSTextField
#
class UiText extends UiControl

  # Create a UiText instance
  #
  # @param tag [String] Tag of the UiControl instance (each control for one delegateName must have a different tag)
  # @param parent [Window] The Window instance this button is connect with
  # @param UiClass [String] The name of the Cocoac control calls to instantiate
  # @param delegateName [String] Name of delegate to be created. If missing, no delegate gets created
  # @param init [Array<String>] An array of Cocoa selectors and parameters.
  #
  constructor: (tag, parent, UiClass, delegateName=null, init=["init"]) ->
    super tag, parent, UiClass, delegateName, init

  # Register/initialize the delgate class the UiText instance
  #
  init: ->
    if @delegate
      @nscontrol "setDelegate", @delegate.init()
    return @

  # Define whether the UiText control is editaböe
  #
  # @param flag [Boolean] Set the UiText instance to editable (true) or non editable (false)
  #
  # @return [UiControl] To allow call chaining
  #
  setEditable: (flag) ->
    @nscontrol "setEditable", flag
    return @

  # Set text of the UiText instance
  #
  # @param text [String] The text to be inserted
  #
  # @return [UiText] To allow call chaining
  #
  setText: (text) ->
    @nscontrol "setStringValue", $(text)
    return @

  # Get text of the UiText instance
  #
  # @return [String] The text of the uiText instance
  #
  getText: ->
    (@nscontrol "stringValue").toString()
    
  # Register a callback when the editing the text control is started
  #
  # @param callback [Function] The callback that will be called when the editing is started
  #
  # @return [UiText] To allow call chaining
  #
  onBeginEditing: (callback) ->
    selector = if @type == "textview" then "textDidBeginEditing:" else "controlTextDidBeginEditing:"
    @delegate.addMethod selector, "v@:@", callback
    return @

  # Register a callback when the editing the text control is finished
  #
  # @param callback [Function] The callback that will be called when the editing is finished
  #
  # @return [Uitext] To allow call chaining
  #
  onEndEditing: (callback) ->
    selector = if @type == "textview" then "textDidEndEditing:" else "controlTextDidEndEditing:"
    @delegate.addMethod selector, "v@:@", callback
    return @



exports.UiControl = UiControl
exports.UiButton = UiButton
exports.UiText = UiText
