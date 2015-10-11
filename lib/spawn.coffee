{spawn} = require "child_process"
{_extend} = require "util"

childHeader = "COCOA_UI_CHILD"
childFlag = "1"

# The Spawn class allows to create a child process
#
# @example
#   {isMaster, createDebug} = require "cocoa-ui"
#   
#   if isMaster()
#     console.log "This is running in the master process"
#     spawn = new Spawn process.env
#     console.log "Creating child process"
#     spawn.createChild()
#   else
#     console.log "This is running in the child process"
#
class Spawn
  
  # Construct a new Spawn object
  #
  constructor: (@argv) ->
    @child = undefined

  # Create the child process
  #
  # @return [Child] The object describing the child
  #
  createChild: ->
    childObject = {}
    childObject[childHeader] = childFlag
    env = _extend(childObject, process.env)
    @child = spawn("#{process.argv[0]}", process.argv[1..], { stdio: [0, 1, 2], env: env })

  # Stop child process
  #
  stopChild: ->
    @child.kill()

# Help function to determine from process environment whether a proces is master or child
#
isMaster = ->
  process.env[childHeader] != childFlag


exports.Spawn = Spawn
exports.isMaster = isMaster