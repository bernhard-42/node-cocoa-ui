{createDebug} = require("./debug")
{isMaster} = require("./spawn")
{AppProxy} = require("./app-proxy")

# direct export
exports.createDebug = createDebug
exports.isMaster = isMaster
exports.AppProxy = AppProxy

# Indirect export to control time when Cocoa frameworks are imported
#
# @example
#  App = require("cocoa-ui").App()
#  app = new App()
#
exports.App = ->           require("./cocoa-app").App

# Indirect export to control time when Cocoa frameworks are imported
#
# @example
#  warningAlert = require("cocoa-ui").warningAlert()
#
exports.warningAlert = ->  require("./cocoa-alert").warningAlert

# Indirect export to control time when Cocoa frameworks are imported
#
# @example
#  infoAlert = require("cocoa-ui").infoAlert()
#
exports.infoAlert = ->     require("./cocoa-alert").infoAlert

# Indirect export to control time when Cocoa frameworks are imported
#
# @example
#  criticalAlert = require("cocoa-ui").criticalAlert()
#
exports.criticalAlert = -> require("./cocoa-alert").criticalAlert