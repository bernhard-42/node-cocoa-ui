$ = require "NodObjC"
$.import "AppKit"
{array} = require "./cocoa-utils"


# Base function for showing file dialogs
# @private
#
# @param nswindow [NSWindow]
# @param dialog [NSOpenPanel or NSSavePanel]
# @param handlerBlock [Block]
# @param options [String] see openDialog and saveDialog
#
# @return [NSOpenPanel or NSSavePanel] The Cocoa file dialog instance
#
fileDialog = (nswindow, dialog, handlerBlock, options={}) ->
  if options.folder
    if options.folder[0] == "."
      startFolder = "#{process.cwd()}#{options.folder}"
    dialog "setDirectoryURL", $.NSURL("URLWithString", $("file://#{options.folder}"))
  
  dialog "setCanChooseFiles", $.YES if options.chooseFiles
  dialog "setCanChooseDirectories", $.YES if options.chooseFolders
  dialog "setPrompt", $(options.prompt) if options.prompt
  dialog "setMessage", $(options.message) if options.message
  dialog "setShowsHiddenFiles", $.YES if options.hiddenFiles
  dialog "setTitle", $(options.title) if options.title if nswindow

  if nswindow   # modal dialog
    dialog "beginSheetModalForWindow", nswindow, "completionHandler", handlerBlock
  else
    dialog "beginWithCompletionHandler", handlerBlock


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
#   nonModalDialog = openDialog(null, (selection) ->
#     console.log selection
#   , options)
#
#   modalDialog = openDialog(nswindow, (selection) ->
#     console.log selection
#   , options)
#
#
# @param nswindow [NSWindow] if null a non modal dialog will be opened, else a model dialog of the given NSWindow instance
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
# @return [NSOpenPanel] The Cocoa file dialog instance
#
openDialog = (nswindow, callback, options) ->
  dialog = $.NSOpenPanel "openPanel"
  dialog "setAllowsMultipleSelection", $.YES if options.multipleSelection
  handlerBlock = $( (self, e) ->
    urls = []
    if e == 1
      urls = (unescape(u("absoluteString").toString()).replace("file://", "") for u in array(dialog "URLs"))
    callback urls
  , ['v',['?', 'i']])
  fileDialog(nswindow, dialog, handlerBlock, options)


# Open the system file save dialog as a modal dialog of the window
#
# @example
#   options =
#     folder:"/Users/bernhard/Development"
#     chooseFiles: true
#     hiddenFiles: true
#     title: "Test save"
#     prompt: "Save it"
#     message: "Save file"
#
#   nonModalDialog = saveDialog(null, (selection) ->
#     console.log selection
#   , options)
#
#   modalDialog = saveDialog(nswindow, (selection) ->
#     console.log selection
#   , options)
#
# @param nswindow [NSWindow] if null a non modal dialog will be opened, else a model dialog of the given NSWindow instance
# @param callback [function] The function to be called after a filename has been selected or dialog has been cancelled
# @option options [String] folder Starting folder
# @option options [Boolean] chooseFiles Allow to select files
# @option options [Boolean] hiddenFiles Show hidden files/folders
# @option options [String] title Title of the dialog window
# @option options [String] prompt Prompt shown in the save File Dialog
# @option options [String] message Message shown in the save File Dialog
#
# @return [NSSavePanel] The Cocoa file dialog instance
#
saveDialog = (nswindow, callback, options) ->
  dialog = $.NSSavePanel "savePanel"
  dialog "setShowsTagField", $.NO
  handlerBlock = $( (self, e) ->
    folder = filename = null
    if e == 1
      folder = dialog("directoryURL").toString().replace("file://", "")
      filename = dialog("nameFieldStringValue").toString()
    callback folder, filename
  , ['v',['?', 'i']])
  fileDialog(nswindow, dialog, handlerBlock, options)


exports.openDialog = openDialog
exports.saveDialog = saveDialog