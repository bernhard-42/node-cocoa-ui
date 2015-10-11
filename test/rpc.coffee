console.log "not working"
process.exit(1)

if false
  app.call("abc")(42)
  .then (result) ->
    console.log result

  app.window("mainWindou").call("abc")(42)
  .then (result) ->
    console.log result

  app.window("mainWindow").call("abc")(42)
  .then (result) ->
    console.log result

  app.window("mainWindou").control("outpuut").call("abc")(42)
  .then (result) ->
    console.log result

  app.window("mainWindow").control("outpuut").call("abc")(42)
  .then (result) ->
    console.log result

  app.window("mainWindow").control("output").call("abc")(42)
  .then (result) ->
    console.log result
