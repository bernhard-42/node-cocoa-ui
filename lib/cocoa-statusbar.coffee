"use strict"

$ = require "NodObjC"
$.import "AppKit"
{StatusMenu} = require "./cocoa-menu"


# The StatusBar class creates an entry in the Cocoa status bar and wraps them into a coffeescript object
#
# @note It is important to call `init()` at the end to register and properly instantiate the delegate class.
#
# @example
#   menuConfig =
#     "StatusMenu": [   # name not used
#       "WithSubMenus": [
#         {title:"SubMenu 1", action: (-> console.log ("Status Submenu 1")), key:""}
#         "FurtherSubMenus": [
#           {title:"SubMenu 2.1", action: (-> console.log ("Status Submenu 2.1")), key:""}
#           {title:"SubMenu 2.2", action: (-> console.log ("Status Submenu 2.2")), key:""}
#         ]
#         {title:"SubMenu 3", action: (-> console.log ("Status Submenu 3")), key:""}
#       ]
#       {title: "Quit #{name}", action: "terminate", key: "q"}
#     ]
#   statusbar = new StatusBar(@, imagePath, menuConfig, name)
#   .init()
#
class StatusBar

  # Create a new StatusBar entry. The Cocoa NSStatusBar instance can be accessed via property "nscontrol"
  #
  # @param parent [Window] The Window instance this button is connect with
  # @param imagePath [String] Fully qualified path to the image (jpg or png)
  # @param menuConfig [Object] Menu definition, see example
  # @param title [String] An alternative title (optional)
  #
  constructor: (@parent, @imagePath, menuConfig, @title=null) ->
    @type = "statusBar"

    systemStatusBar = $.NSStatusBar "systemStatusBar"
    @nscontrol = systemStatusBar "statusItemWithLength", -1 #$.NSVariableStatusItemLength
    @nscontrol "retain"   # necessary, else icon disappears ...
    @setImage()
    @setMenu(menuConfig)

  # Set an image for the StatusBar icon
  #
  # @return [StatusBar] To allow call chaining
  #
  setImage: ->
    image = $.NSImage("alloc")("initWithContentsOfFile", $(@imagePath))
    if @nscontrol "respondsToSelector", "button:"   # is it Yosemite?
      image.template = $.YES
      @nscontrol("button")("setImage", image)
      @nscontrol("button")("setAccessibilityTitle", $(@title)) if @title
      @nscontrol("button")("setAppearsDisabled", $.NO)
    else
      @nscontrol "setImage", image
    return @

  # Define and set the menu behind the StatusBar icon
  #
  # @param menuConfig [Object] Menu definition, see example
  #
  setMenu: (menuConfig) ->
    @menu = new StatusMenu(@parent, menuConfig)
    @nscontrol("setMenu", @menu.statusMenu.nsmenu)

  # Register/initialize the delgate class the RadioButtons instance
  #
  init: ->
    @menu.init()


exports.StatusBar = StatusBar


