"use strict"

$ = require "NodObjC"
$.import "AppKit"

{Delegate} = require "./cocoa-delegate"
{UiControl} = require "./cocoa-uicontrol"

#  class
# The ProgressIndicator class creates a Cocoa progress indicator and wraps them into a coffeescript object
#
# @example
#   image = new Image("image", window, "/tmp/image.jpeg")
#
class ProgressIndicator extends UiControl

  # Construct a ProgressIndicator
  # If minValue or maxValue or both are omitted, an indeterminate spinning "wheel" will be shown,
  # else a linear progress indicator
  #
  # @example
  #   # indeterminate
  #   progress = window.addProgressIndicator("spin")
  #   progress.start()
  #   setTimeout((-> progess.stop()), 1000)
  #
  #   # determinate
  #   progress = window.addProgressIndicator("progress", 0, 10)
  #   progress.increment(0.5)
  #   setTimeout((-> progess.increment(2.5)), 1000)
  #
  # @param tag [String] Name or tag of the ProgressIndicator instance (each control of a one type must have a different tag)
  # @param parent [Window] The Window instance this progress indicator is connect with
  # @param minValue [Intger] Minimum value of the slider (optional)
  # @param maxValue [Integer] Maximum value of the slider (optional)
  #
  constructor: (tag, parent, @minValue=null, @maxValue=null) ->
    super tag, parent, $.NSProgressIndicator
    @type = "progressbar"
    @indeterminate = not @maxValue? or not @minValue?
    if @indeterminate
      @nscontrol "setStyle", $.NSProgressIndicatorSpinningStyle
      @nscontrol "setIndeterminate", $.YES
    else
      @nscontrol "setStyle", $.NSProgressIndicatorBarStyle
      @nscontrol "setIndeterminate", $.NO
      @nscontrol "setMinValue", @minValue
      @nscontrol "setMaxValue", @maxValue

  # Start an indeterminate progress indicator (spinning wheel)
  #
  start: ->
    @nscontrol("startAnimation", @parent.nscontrol) if @indeterminate

  # Stop an indeterminate progress indicator (spinning wheel)
  #
  stop: ->
    @nscontrol("stopAnimation", @parent.nscontrol) if @indeterminate

  # Increment a determinate progress indicator (progress bar)
  #
  # @param value [Float] Value to increment the indicator
  #
  increment: (value) ->
    @nscontrol("incrementBy", value * 1.0) if not @indeterminate
    
  # Set a determinate progress indicator (progress bar) to a specific value
  #
  # @param value [Float] New value of the indicator
  #
  setValue: (value) ->
    @nscontrol("setDoubleValue", value * 1.0) if not @indeterminate

  # Get minValue and MaxValue of a determinate progress indicator (progress bar)
  #
  # @return value [Array<Float>] A two element array [minValue, maxValue]
  #
  getMinMax: ->
    return [@minValue, @maxValue]

exports.ProgressIndicator = ProgressIndicator