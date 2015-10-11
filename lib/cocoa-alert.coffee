"use strict"

$ = require "NodObjC"
$.import "AppKit"

# Base function for showing alerts
# @private
#
# @param style [Integer] Can be $.NSWarningAlertStyle, $.NSInformationalAlertStyle or $.NSCriticalAlertStyle
# @param message [Integer] Message text shown in dialog title
# @param info [Integer] Info to be displayed
# @param buttons [Array<String>] Array of button labels
#
# @return [Integer] the index of the pressed button, starting with 0
#
alert = (style, message, info, buttons) ->
  dialog = $.NSAlert("alloc")("init")
  dialog("setAlertStyle", style)
  dialog("setMessageText", $(message)) if message
  dialog("setInformativeText", $(info)) if info
  for button in buttons
    dialog("addButtonWithTitle", $(button))
  ret = (dialog "runModal")
  return ret - 1000

# Function for showing warning alerts
#
# @param message [Integer] Message text shown in dialog title
# @param info [Integer] Info to be displayed
# @param buttons [Array<String>] Array of button labels
#
# @return [Integer] the index of the pressed button, starting with 0
#
warningAlert = (message, info, buttons) ->
  alert($.NSWarningAlertStyle, message, info, buttons)

# Function for showing info alerts
#
# @param message [Integer] Message text shown in dialog title
# @param info [Integer] Info to be displayed
# @param buttons [Array<String>] Array of button labels
#
# @return [Integer] the index of the pressed button, starting with 0
#
infoAlert = (message, info, buttons) ->
  alert($.NSInformationalAlertStyle, message, info, buttons)

# Function for showing critical alerts
#
# @param message [Integer] Message text shown in dialog title
# @param info [Integer] Info to be displayed
# @param buttons [Array<String>] Array of button labels
#
# @return [Integer] the index of the pressed button, starting with 0
#
criticalAlert = (message, info, buttons) ->
  alert($.NSCriticalAlertStyle, message, info, buttons)


exports.warningAlert = warningAlert
exports.infoAlert = infoAlert
exports.criticalAlert = criticalAlert