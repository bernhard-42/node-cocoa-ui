"use strict"

$ = require "NodObjC"
$.import "AppKit"

# Delegate class for all UI elements to create a Cocoa delegate that will
# implement the callbacks and hooks.
#
# @note It is important to call `init()` at the end to register and properly instantiate the delegate class.
#
# @example How to create a delegate
#   class SomeControl
#     constructor: (tag, parent, title) ->
#       @nscontrol = $NS...("alloc")("init...", ...)
#       @delgate = new Delegate("CocoacClassName")
#
#     init: ->
#       delegate.init()
#       @nscontrol("setTarget", @delegate.init())  # or "setAction" depending on which Cocoa control is used
#
class Delegate

  # Construct a new Delegate
  # @param delegateClassName [String] Name of the Cocoa delegate class
  #
  constructor: (delegateClassName) ->
    @nsdelegate = $.NSObject.extend(delegateClassName)
    @instance = null

  # Add an instance variable to the **Cocoa** delegate class
  #
  # @example
  #   delegate = new Delegate("Example")
  #   delegate.addIvar "myInstanceVar", "@"
  #
  # @param name [String] Name of the instance variable
  # @param type [type] Objective-C type encoding (@see https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html)
  #
  # @return [Delegate] the **node** delegate instance to allow chaining
  #
  addIvar: (name, type) ->
    @nsdelegate.addIvar(name, type)
    return @

  # Add an instance method to the delegate class
  #
  # @example
  #   delegate = new Delegate("Example")
  #   delegate.addMethod("onClick", "v@:@", (-> console.log "called"))
  #
  # Remember to call init() after last addMethod call
  #
  # @param event [String] name of the method
  # @param signature [String] type encoded signature (see https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html)
  # @param callback [Function] the function to be called when the event is fired
  #
  # @return [Delegate] the **node** delegate instance to allow chaining
  #
  addMethod: (event, signature, callback) ->
    @nsdelegate.addMethod("#{event}", signature, (self, sel, args...) -> callback(self, sel, args...))
    return @

  # Register, allocate and init the delegate class, to be called after all addMethod
  # calls have been issued
  # @return [NSObject] the **Cocoa** delegate
  #
  init: ->
    @nsdelegate.register()
    @instance = @nsdelegate("alloc")("init")
    return @instance   # return instance and not the class


exports.Delegate = Delegate
