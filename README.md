## An attempt to build native Cocoa UIs with NodObjC

###Issue:
Cocoa Event loop and node event loop do not play together too well ...

###Different apporach:
Split Cocoa part and node code into two processes via child_process and use an RPC mechanism to communicate between both: 

- The Cocoa part will run in node controlled by Cocoa event loop and use AsyncSocketFramework for communication
- The node part will run in node event loop and use net.Socket for communication

Find examples in `example`:

    cd example
    coffee simple-app.coffee
    coffee app.coffee


###Test app:

    cd examples
    ../bin/createStandaloneApp.sh TestApp com.example.cocoaui CocoaUiDemo.icns app.coffee ui.coffee

and double click `TestApp`


###To debug ignore building an application and call

  cd examples
  DEBUG=cocoa-ui* coffee app.coffee

### Known issue:

- If client or server crashes, the other process might survive. Use `kill` to kill it
