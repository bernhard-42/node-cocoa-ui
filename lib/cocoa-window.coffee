"use strict"

$ = require "NodObjC"
$.import "AppKit"

{Delegate} = require "./cocoa-delegate"
{View} = require "./cocoa-view"
{TextView, ScrollView} = require "./cocoa-textview"
{TextField} = require "./cocoa-textfield"
{Button} = require "./cocoa-button"
{Label} = require "./cocoa-label"
{RadioButtons} = require "./cocoa-radiobutton"
{CheckBox} = require "./cocoa-checkbox"
{ComboBox} = require "./cocoa-combobox"
{Slider} = require "./cocoa-slider"
{Image} = require "./cocoa-image"
{ProgressIndicator} = require "./cocoa-progress"
{saveDialog, openDialog} = require "./cocoa-filedialog"

# Window class creates a Cocoa window and wraps it into a coffeescript object
#
# @note It is important to call `init()` at the end to register and properly instantiate the delegate class.
#
# @example
#   window = new Window(app, "mainWindow", title, ["Titled", "Resizable", "Miniaturizable", "Closable"])
#   .cascadeTopLeftFromPoint 20, 20
#   .onResize ->   debug "resized"
#   .onMinimize -> debug "minimize"
#   .onMaximize -> debug "maximize"
#   .onClose ->    debug "close"
#   .init()
#
class Window

  # Create a new Window. The Cocoa NSWindiw instance can be accessed via property "nswindow"
  #
  # @param app [App] The App instance containing the window
  # @param tag [String] Tag of window (each window must have a different tag)
  # @param title [String] Window title
  # @param styles [Array<String>] Style Strings can be: "Titled", "Resizable", "Miniaturizable", "Closable"
  # @param width [] Width of window default=0. Usually not used, due to Autolayout support
  # @param height [] Height of window default=0. Usually not used, due to Autolayout support
  #
  constructor: (@app, tag, title, styles, width=0, height=0) ->
    styleMask = ($["NS#{x}WindowMask"] for x in styles).reduce (a,b) -> a | b
    @nswindow = $.NSWindow("alloc")("initWithContentRect", $.NSMakeRect(0, 0, width, height),
                                    "styleMask", styleMask,
                                    "backing", $.NSBackingStoreBuffered,
                                    "defer", false)
    @type = "window"
    @doNotSerialize = true   # do not stringify for RPC returns
    @nswindow "setTitle", $(title) if title
    @nswindow "makeKeyAndOrderFront", null
    @controls = []
    @methods = {}
    @delegate = new Delegate "WindowDelegate_#{tag}"

  # Register/initialize the delgate class the Cocoa window instance for "on..." callbacks
  #
  init: ->
    @nswindow "setDelegate", @delegate.init()
    return @

  # Open the system file open dialog as a modal dialog of the window
  #
  # @example
  #   options =
  #     folder:"/Users/bernhard/Development"
  #     multipleSelection: true
  #     chooseFolders: true
  #     chooseFiles: true
  #     hiddenFiles: true
  #     title: "Test open"
  #     prompt: "Get it"
  #     message: "Select multiple files as you like"
  #
  #   window.openDialog((selection) ->
  #     console.log selection
  #   , options)
  #
  # @param callback [function] The function to be called after file(s) have been selected or dialog has been cancelled
  # @option options [String] folder Starting folder
  # @option options [Boolean] multipleSelection Allow to select more than one file
  # @option options [Boolean] chooseFolders Allow to select folders (instead of opening them)
  # @option options [Boolean] chooseFiles Allow to select files
  # @option options [Boolean] hiddenFiles Show hidden files/folders
  # @option options [String] title Title of the dialog window
  # @option options [String] prompt Prompt shown in the open File Dialog
  # @option options [String] message Message shown in the open File Dialog
  #
  # return [NSOpenPanel] the Cocoa dialog instance
  #
  openDialog: (callback, options={}) ->
    openDialog @nswindow, callback, options

  # Open the system file save dialog as a modal dialog of the window
  #
  # @example
  #   options =
  #     folder:"/Users/bernhard/Development"
  #     chooseFiles: true
  #     hiddenFiles: true
  #     title: "Test save"
  #     prompt: "SAve it"
  #     message: "save file"
  #
  #   window.saveDialog((selection) ->
  #     console.log selection
  #   , options)
  #
  # @param callback [function] The function to be called after a filename has been selected or dialog has been cancelled
  # @option options [String] folder Starting folder
  # @option options [Boolean] chooseFiles Allow to select files
  # @option options [Boolean] hiddenFiles Show hidden files/folders
  # @option options [String] title Title of the dialog window
  # @option options [String] prompt Prompt shown in the save File Dialog
  # @option options [String] message Message shown in the save File Dialog
  #
  # return [NSSavePanel] the Cocoa dialog instance
  #
  saveDialog: (callback, options={}) ->
    saveDialog @nswindow, callback, options


  # Register a callback for the Cocoa windowDidResize event
  #
  # @param callback [Function] The callback that will be called when Cocoa fires windowDidResize
  #
  # @return [Window] To allow call chaining
  #
  onResize: (callback) ->
    @delegate.addMethod "windowDidResize:", "v@:@", callback
    return @

  # Register a callback for the Cocoa windowWillMiniaturize event
  #
  # @param callback [Function] The callback that will be called when Cocoa fires windowWillMiniaturize
  #
  # @return [Window] To allow call chaining
  #
  onMinimize: (callback) ->
    @delegate.addMethod "windowWillMiniaturize:", "v@:@", callback
    return @

  # Register a callback for the Cocoa windowDidDeminiaturize event
  #
  # @param callback [Function] The callback that will be called when Cocoa fires windowDidDeminiaturize
  #
  # @return [Window] To allow call chaining
  #
  onMaximize: (callback) ->
    @delegate.addMethod "windowDidDeminiaturize:", "v@:@", callback
    return @

  # Register a callback for the Cocoa windowWillClose event
  #
  # @param callback [Function] The callback that will be called when Cocoa fires windowWillClose
  #
  # @return [Window] To allow call chaining
  #
  onClose: (callback) ->
    @delegate.addMethod "windowWillClose:", "v@:@", callback
    return @

  # onFocus: (callback) ->
  #   @delegate.addMethod "didBecomeKey:", "v@:@", callback
  #   return @

  # Open the Cocoa windw x pixel right and y pixel below of the last window
  #
  # @param x [Integer] Number of pixels to shift right
  # @param x [Integer] Number of pixels to shift down
  #
  # @return [Window] To allow call chaining
  #
  cascadeTopLeftFromPoint: (x, y) ->
    @nswindow "cascadeTopLeftFromPoint", $.NSMakePoint(x, y)
    return @

  # Center the Cocoa window
  #
  center: ->
    @nswindow "center"
    return @

  # Close the Cocoa window
  #
  close: ->
    @nswindow "close"
    return null

  # Set the main Cocoa view of a Cocoa window
  # @param nsview [NSView] The Cocoa view instance
  #
  # @return [Window] To allow call chaining
  #
  setContentView: (nsview) ->
    @nswindow "setContentView", nsview
    return @

  # Convenience method to add a View to an app
  #
  # @example
  #    view = window.addView("someview")
  #
  # @param tag [String] Name or tag of the View instance
  #
  # @return [View] The new View instance
  #
  addView: (tag) ->
    return @controls[tag] = new View(tag, @)

  # Convenience method to add a the main View to an app
  #
  # @example
  #   mainview = window.addMainView("mainview")
  #
  # @param tag [String] Name or tag of the View instance
  #
  # @return [View] The View instance
  #
  addMainView: (tag) ->
    ret = @addView tag
    ret.makeContentView()
    return ret

  # Convenience method to add a label to a window
  #
  # @example
  #   label = window.addLabel("label", "A Label")
  #
  # @param tag [String] Name or tag of the Label view
  # @param title [String] The text shown in the label
  #
  # @return [] The Label instance
  #
  addLabel: (tag, title) ->
    return @controls[tag] = new Label(tag, @, title)

  # Convenience method to add a CheckBox to a window
  #
  # @example
  #   checkbox = window.addCheckBox("checkbox", "xyz")
  #
  # @param tag [String] Name or tag of the Checkbox instance
  # @param title [String] The text shown in the checkbox
  #
  # @return [CheckBox] The CheckBox instance
  #
  addCheckBox: (tag, title) ->
    return @controls[tag] = new CheckBox(tag, @, title)

  # Convenience method to add a Button to a window
  #
  # @example
  #   button = window.addButton("ok", "OK")
  #
  # @param tag [String] Name or tag of the Button instance
  # @param title [String] The text shown on the button
  #
  # @return [Button] The Button instance
  #
  addButton: (tag, title) ->
    return @controls[tag] = new Button(tag, @, title)

  # Convenience method to add a TextField to a window
  #
  # @example
  #    textfield = window.addTextField("textfield", "This is a text")
  #
  # @param tag [String] Name or tag of the TextField instance
  # @param text [String] Text to be shown in the text field
  #
  # @return [TextField] The TextField instance
  #
  addTextField: (tag, text) ->
    return @controls[tag] = new TextField(tag, @, text)

  # Convenience method to add an Image to a window
  #
  # @example
  #    image = window.addImage("image", "/tmp/NodeCocoa.jpg")
  #
  # @param tag [String] Name or tag of the Image instance
  # @param imagePath [String] Fully qualified path to the image (jpg or png)
  #
  # @return [Image] The Image instance
  #
  addImage: (tag, imagePath) ->
    return @controls[tag] = new Image(tag, @, imagePath)

  # Convenience method to add a TextView to a window
  #
  # @example
  #   textview = window.addTextView("textview")
  #
  # @param tag [String] Name or tag of the TextView instance
  #
  # @return [TextView] The TextView instance
  #
  addTextView: (tag) ->
    return @controls[tag] = new TextView(tag, @)

  # Convenience method to add a ScrollView for a TextView to a window
  #
  # @example
  #   textview = window.addTextView("textview")
  #   scrollview = window.addScrollView("scrollview", textview)
  #
  # @param tag [String] Name or tag of the ScrollView instance
  # @param text [String] The textView instance to be embedded in the ScrollView
  #
  # @return [ScrollView] The ScrollView instance
  #
  addScrollView: (tag, textview, hscroll=true, vscroll=true) ->
    return @controls[tag] = new ScrollView(tag, @, textview, hscroll, vscroll)

  # Convenience method to add a set of radio buttons (RadioButtons) to a window
  #
  # @example
  #   choices = [ 'The quick', 'brown fox', 'jumps over', 'the lazy dog']
  #   radiobuttons = window.addRadioButtons("radio", choices)
  #
  # @param tag [String] Name or tag of the RadioButtons instance
  # @param choices [Array<String>] List of labels for each radio button
  #
  # @return [RadioButtons] The RadioButtons instance
  #
  addRadioButtons: (tag, choices) ->
    return @controls[tag] = new RadioButtons(tag, @, choices)

  # Convenience method to add a ComboBox to a window
  #
  # @example
  #   choices = [ 'The quick', 'brown fox', 'jumps over', 'the lazy dog']
  #   combobox = window.addComboBox("combobox", choices)
  #
  # @param tag [String] Name or tag of the XXXX control to add
  # @param elements [Array<String>] List of labels to add as default values to the combo box
  #
  # @return [ComboBox] The ComboBox instance
  #
  addComboBox: (tag, elements) ->
    return @controls[tag] = new ComboBox(tag, @, elements)

  # Convenience method to add a Slider to a window
  #
  # @example
  #   slider = window.addSlider("slider", 0, 10)
  #
  # @param tag [String] Name or tag of the Slider instance
  # @param minValue [Intger] Minimum value of the slider
  # @param maxValue [Integer] Maximum value of the slider
  # @param circular [Boolean] If true will add a circular slider (optional)
  #
  # @return [Slider] The Slider instance
  #
  addSlider: (tag, minValue, maxValue, circular=false) ->
    return @controls[tag] = new Slider(tag, @, minValue, maxValue, circular)

  # Convenience method to add a ProgressIndicator to a window
  # If minValue or maxValue or both are omitted, an indeterminate spinning "wheel" will be shown,
  # else a linear progress indicator
  #
  # @example
  #   # indeterminate
  #   progress = window.addProgressIndicator("spin")
  #   # determinate
  #   progress = window.addProgressIndicator("progress", 0, 10)
  #
  # @param tag [String] Name or tag of the Slider instance
  # @param minValue [Intger] Minimum value of the slider (optional)
  # @param maxValue [Integer] Maximum value of the slider (optional)
  #
  # @return [ProgressIndicator] The ProgressIndicator instance
  #
  addProgressIndicator: (tag, minValue, maxValue) ->
    return @controls[tag] = new ProgressIndicator(tag, @, minValue, maxValue)

exports.Window = Window
