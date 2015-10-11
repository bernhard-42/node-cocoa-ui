"use strict"

$ = require "NodObjC"
$.import "AppKit"

{nsdict} = require "./cocoa-utils"
{UiControl} = require "./cocoa-uicontrol"


# Helper functions to create NSLayoutConstraints
#
# @param constraint [String] A single VFL constraint
# @param metrics [Object] An Object continaing the measures used in the constraint 
# @param views [Array<Object>] An Array of UI controls used in the constraint
# @param options [Integer] An optional layout paramter - currently unused
#
# @return [NSLayoutConstraint] The Cocoa layout constraint
#
createConstraint = (constraint, metrics, views, options=0) ->
  $.NSLayoutConstraint "constraintsWithVisualFormat", $(constraint),
                       "options", options,
                       "metrics", if metrics then metrics else null,
                       "views", views

# The View class creates a Cocoa view and wraps them into a coffeescript object
#
class View extends UiControl

  # Create a new View. The Cocoa NSView instance can be accessed via property "nscontrol"
  #
  # @param tag [String] Tag of the Button instance (each control of a one type must have a different tag)
  # @param parent [Window] The Window instance this button is connect with
  #
  constructor: (tag, parent) ->
    super tag, parent, $.NSView
    @type = "view"
    @chacheMetrics = null
    @cacheViews = null
    
  # The library uses Apples AutoLayout and the Visual Format Language (VFL)
  # @see https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage/VisualFormatLanguage.html
  #
  # @example
  #   views = [clock, inputfield, scrollview, changecase, quit]
  #   view.addSubview v for v in views
  #   metrics = {h1:200, h2:15, h3:20, w1:400, w2:80}   # ... define some metrics ...
  #   constraints = [                                   # ... and constraints ....
  #     "H:|-[input(>=w1)]-[clock(w2)]-|"               # (use tags from control definitions and metric keys)
  #     "H:|-[scroll(>=w1)]-[change(w2)]-|"
  #     "H:|-[scroll(>=w1)]-[quit(w2)]-|"
  #     "V:|-[input(>=h1)]-[scroll(>=h1)]-|"
  #     "V:|-[clock(h2)]"
  #     "V:[change(h3)]-(4)-[quit(h3)]-|"
  #   ]
  #   for constraint in constraints
  #     view.setLayout(constraint, metrics, views)
  #
  # @param constraint [String] A single VFL constraint
  # @param metrics [Object] An Object continaing the measures used in the constraint 
  # @param views [Array<Object>] An Array of UI controls used in the constraint
  #
  # @return [View] To enable call chaining
  #
  setLayout: (constraint, metrics, views) ->
    viewsDict = {}
    viewsDict[v.tag] = v.nscontrol for v in views
    @cacheViews = @cacheViews ? nsdict(viewsDict)
    @cacheMetrics = @cacheMetrics ? nsdict(metrics)
    @addConstraints createConstraint(constraint, @cacheMetrics, @cacheViews)
    return @

  # Add constraints to a view
  #
  # @param constraints [Array<String>] An array of VFL constrint strings
  #
  # @return [View] To enable call chaining
  #
  addConstraints: (constraints) ->
    @nscontrol "addConstraints", constraints
    return @

  # Add a subview to a view
  #
  # @param subview [View] The view to be added as subview
  #
  # @return [View] To enable call chaining
  #
  addSubview: (subview) ->
    @nscontrol "addSubview", subview.nscontrol
    return @

  # Make this view as content view of the parent window
  #
  # @return [View] To enable call chaining
  #
  makeContentView: ->
    @parent.setContentView @nscontrol
    return @

exports.View = View
