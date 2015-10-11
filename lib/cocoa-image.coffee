"use strict"

$ = require "NodObjC"
$.import "AppKit"

{UiButton} = require "./cocoa-uicontrol"

# The Image class creates a Cocoa image view and wraps them into a coffeescript object
#
# @example
#   image = new Image("image", window, "/tmp/image.jpeg")
#
class Image extends UiButton

  # Create a new Image. The Cocoa NSImageView instance can be accessed via property "nscontrol"
  #
  # @param tag [String] Name or tag of the Image instance (each control of a one type must have a different tag)
  # @param parent [Window] The Window instance this button is connect with
  # @param imagePath [String] Fully qualified path to the image (jpg or png)
  #
  constructor: (tag, parent, imagePath=null) ->
    super tag, parent, $.NSImageView, "ImageView"
    @type = "image"
    @nscontrol "setImageScaling", $.NSImageScaleProportionallyDown
    @setImage imagePath if imagePath

  # Set an image for the ImageView
  #
  # @param imagePath [String] Fully qualified path to the image (jpg or png)
  #
  # @return [Image] The Image instance
  #
  setImage: (imagePath) ->
    image = $.NSImage("alloc")("initWithContentsOfFile", $(imagePath))
    @nscontrol "setImage", image
    return @


exports.Image = Image
