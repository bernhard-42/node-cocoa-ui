"use strict"

$ = require "NodObjC"
$.import "AppKit"

{UiButton} = require "./cocoa-uicontrol"

# The Slider class creates a Cocoa slider and wraps them into a coffeescript object
#
# @note It is important to call `init()` at the end to register and properly instantiate the delegate class.
#
# @example
#   slider = window.addSlider("slider", 0, 10)
#   .numTicks 11
#   .snapToTicks true
#   .setValue 5
#   .onMoved -> console.log(slider.getValue())
#   .init()
#
class Slider extends UiButton

  # Create a new slider. The Cocoa NSSlider instance can be accessed via property "nscontrol"
  #
  # @param tag [String] Tag of the Slider instance (each control of a one type must have a different tag)
  # @param parent [Window] The Window instance this button is connect with
  # @param minValue [Integer] Minimum value of slider
  # @param maxValue [Integer] Maximum value of slider
  # @param circular [Boolean] Circular (true) or linear slider (false)
  #
  constructor: (tag, parent, @minValue=0, @maxValue=1, circular=false) ->
    super tag, parent, $.NSSlider, "UiSlider"
    @type = "slider"
    @cell = $.NSSliderCell("alloc")("init")
    @cell "setSliderType", (if circular then $.NSCircularSlider else $.NSLinearSlider)
    @setMinValue @minValue
    @setMaxValue @maxValue
    @nscontrol "setCell", @cell

  # Set minimum value of the slider
  #
  # @param minValue [Integer] The new minimum value
  #
  # @return [Slider] To allow call chaining
  #
  setMinValue: (minValue) ->
    @cell "setMinValue", minValue
    return @

  # Set maximum value of the slider
  #
  # @param maxValue [Integer] The new maximum value
  #
  # @return [Slider] To allow call chaining
  #
  setMaxValue: (maxValue) ->
    @cell "setMaxValue", maxValue
    return @

  # Set actual shown value of the slider
  #
  # @param value [Integer] The value the slider should be moved to
  #
  # @return [Slider] To allow call chaining
  #
  setValue: (value) ->
    @cell "setDoubleValue", 1.0 * value
    return @

  # Set number of ticks of the slider
  #
  # @param num [Integer] The number of ticks the slider should have
  #
  # @return [Slider] To allow call chaining
  #
  numTicks: (num) ->
    @cell "setNumberOfTickMarks", num
    return @

  # Define whether the slider snaps to the configured ticks
  #
  # @param flag [Boolean] Snap to grid (true)
  #
  # @return [Slider] To allow call chaining
  #
  snapToTicks: (flag) ->
    @cell "setAllowsTickMarkValuesOnly", flag
    return @

  # Get actual shown value of slider
  #
  # @return [Float] The actual value of the slider
  #
  getValue: ->
    @cell "doubleValue"

  # Register a callback when the slider got moved
  #
  # @param callback [Function] The callback that will be called when the slider got moved
  #
  # @return [Window] To allow call chaining
  #
  onMoved: (callback) ->
    @delegate.addMethod "onMoved", "v@:@", callback
    @nscontrol "setAction", "onMoved"
    return @

exports.Slider = Slider
