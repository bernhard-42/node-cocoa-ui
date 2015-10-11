"use strict"

$ = require "NodObjC"
$.import "AppKit"
{Delegate} = require "./cocoa-delegate"

# The Menu class creates a Cocoa NSMenu and wraps them into a coffeescript object
# @private
#
# @example
#   menu = new Menu("Close")
#
class Menu
  
  # Create a new Menu. The Cocoa NSMenu instance can be accessed via property "nscontrol"
  #
  # @param title [String] Title shown as menu entry
  #
  constructor: (title=null) ->
    if title == null
      @nsmenu = $.NSMenu("alloc")("init")
    else
      @nsmenu = $.NSMenu("alloc")("initWithTitle", $(title))
    @type = "menu"

  # Add a wrapped MenuItem item to the menu
  #
  # @param menuItem [MenuItem] The menu item to be added
  #
  # @return [Menu] To allow call chaining
  #
  addItem: (menuItem) ->
    @nsmenu "addItem", menuItem.nsitem
    return @


# The MenuItem class creates a Cocoa NSMenuItem and wraps them into a coffeescript object
# @private
#
# @example
#   options = {title:"Close", action:closeHandler, key:"w", modifiers:["Alternate", "Command"]}
#   menuitem = new MenuItem(options)
#
class MenuItem

  # Create a new MenuItem. The Cocoa NSMenu instance can be accessed via property "nscontrol"
  #
  # @option options [String] title Title of menu item
  # @option options [Function] callback Function to be called when menu item is selected
  # @option options [Character] key Shortcut key to call menu item
  # @option options [Array<String>] modifiers List of modifier keys ("Alternate", "Command", "Control", "Shift")
  #
  constructor: (options=null) ->
    if options is null
      @nsitem = $.NSMenuItem("alloc")("init")
    else
      @nsitem = $.NSMenuItem("alloc")("initWithTitle", $(options.title), \
                                    "action", "#{options.action}", \
                                    "keyEquivalent", $(options.key))
      if options.modifiers
        mask = ($["NS#{x}KeyMask"] for x in options.modifiers).reduce (a,b) -> a | b
        @nsitem("setKeyEquivalentModifierMask", mask)
    @type = "menuitem"
 
  # Set title of a menu item
  #
  # @param title [String] The name of the menu item
  #
  # @return [MenuItem] To allow call chaining
  #
  setTitle: (title) ->
    @nsitem "setTitle", $(title)
    return @

  # Add MenuItem instance as submenu to a Menu instance
  #
  # @param menu [Menu] The Menu instance this menu item shall be added to
  #
  # @return [MenuItem] To allow call chaining
  #
  setSubMenu: (menu) ->
    @nsitem "setSubmenu", menu.nsmenu
    return @


# The MenuFactory class is the base class for AppMenu and StatusMenu
# @private
#
class MenuFactory

  # Create a new MenuFactory instance.
  #
  # @param delegateName [String] Name of dlegate to be created
  #
  constructor: (delegateName) ->
    @delegate = new Delegate(delegateName)
    @targets = []
    @menus = {}

  # Register/initialize the delgate class the MenuFactory instance
  #
  init: ->
    @nsdelegate = @delegate.init()
    # set target for all menu items with custom handlers
    for menuItem in @targets
      menuItem.nsitem "setTarget", @nsdelegate
    return @

  # Create a MenuItem instance for a given menuconfig item
  #
  # @param names [Array<String>] List of menu item entry names in one hierachy of sub menus
  # @param item [Object] Object of form {title:"...", action:..., key:"...", modifiers:[...]} describing the menu item behaviour
  # @param menus [Object] The resulting tree of submenus down from the root menu entry
  #
  # @return [MenuItem] The MenuItem instance created in this step
  #
  createMenuItem: (names, item, menus) ->
    if item == "-"
      menuItem = {nsitem: $.NSMenuItem("separatorItem")}
    else
      if item.title # standard menu item
        if typeof item.action == "function"
          # Create a unique handler name
          handler = "#{names.join("_")}_#{item.title}".replace(/[^\w]/g, "_")
          # register it with AppMenus delegate and the given action
          @delegate.addMethod handler, "v@:@", item.action
          # use the new handler as action
          item2 = {title:item.title, action:handler, key:item.key, modifiers:item.modifiers}
        else
          # add ":" as selector to item.action
          item2 = {title:item.title, action:"#{item.action}:", key:item.key, modifiers:item.modifiers}
        # create the menu item
        menuItem = new MenuItem item2
        # and store it for later access
        menus[item.title] = menuItem
        # remember to set target for menu items with custom handler
        if typeof item.action == "function"
          @targets.push menuItem
      else # submenu
        menuName = Object.keys(item)[0]
        menuItem = @createSubMenu names.concat(menuName), item[menuName], menus
        .setTitle menuName

    return menuItem

  # Create a sub menu in order to allow menu hierarchies
  #
  # @param names [Array<String>] List of menu item entry names in one hierachy of sub menus
  # @param menu [Object] One single menu hierarchy (array) in a menuconfig object
  # @param menus [Object] The resulting tree of submenus down from the root menu entry
  #
  # @return [MenuItem] The sub menu item created
  #
  createSubMenu: (names, menu, menus) ->
    menuName = names[names.length-1]
    subMenu = new Menu menuName
    menus[menuName] = {}
    for item in menu
      menuItem = @createMenuItem names, item, menus[menuName]
      subMenu.addItem menuItem

    subMenuItem = new MenuItem()
    .setSubMenu subMenu


# The AppMenu class creates an Application menu described in a menuconfig object
#
# @example
#   menuConfig =
#     "AppMenu": [      # name not used
#         {title: "About", action: "orderFrontStandardAboutPanel", key: ""}
#         "-"
#         {title: "Preferences", action: preferences, key: ","}
#         "-"
#         {title: "Quit #{name}", action: "terminate", key: "q"}
#       ]
#     "File": [
#         {title:"New",  action:"newDocument", key:"n"}
#         {title:"Open", action:"openDocument", key:"o"}
#         "-"
#         {title:"Close", action:"performClose", key:"w"}
#         {title:"Save...", action:"saveDocument", key:"s"}
#         {title:"Save As...", action:"saveDocumentAs", key:""}
#         "-"
#         "WithSubMenus": [
#           {title:"SubMenu 1", action: (-> console.log ("Submenu 1")), key:""}
#           "FurtherSubMenus": [
#             {title:"SubMenu 2.1", action: (-> console.log ("Submenu 2.1")), key:""}
#             {title:"SubMenu 2.2", action: (-> console.log ("Submenu 2.2")), key:""}
#           ]
#           {title:"SubMenu 3", action: (-> console.log ("Submenu 3")), key:""}
#         ]
#         "-"
#         {title:"Print...", action:"print", key:""}
#
#    menu = new AppMenu(menuConfig)
#    .init()
#
class AppMenu extends MenuFactory

  # Create a new AppMenu instance.
  #
  # @param app [App] The App instance for which the menu is added
  # @param menuConfig [Object] Menu definition, see example
  #
  constructor: (@app, menuConfig) ->
    super("AppMenu")

    @appMenu = new Menu()
    for name, menu of menuConfig
      subMenuItem  = @createSubMenu [name], menu, @menus
      @appMenu.addItem subMenuItem

    # set the final app menu
    @app.setMainMenu @appMenu.nsmenu
    return @


# The StatusMenu class creates an Application menu described in a menuconfig object
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
#   statusMenu = new StatusMenu(menuConfig)
#   .init()
#
class StatusMenu extends MenuFactory

  # Create a new StatusMenu instance.
  #
  # @param app [App] The App instance for twhich the menu is added
  # @param menuConfig [Object] Menu definition, see example
  #
  constructor: (app, menuConfig) ->
    super("StatusMenu")
    @statusMenu = new Menu()
    for name, menu of menuConfig
      for item in menu
        menuItem = @createMenuItem [name], item, @menus
        @statusMenu.addItem menuItem


exports.AppMenu = AppMenu
exports.StatusMenu = StatusMenu

