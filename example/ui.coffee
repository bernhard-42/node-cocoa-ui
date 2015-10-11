lorem = require "lorem-ipsum"

{createDebug} = require "cocoa-ui"
debug = createDebug "UI", 3

criticalAlert = require("cocoa-ui").criticalAlert()

#
# OSX Menu
#
createDefaultMenu = (name, app) ->
  debug "createMenu"

  preferences = ->
    secondWindow app, "Prefs", 0, 10
  
  menuConfig =
    "AppMenu": [      # name not used
        {title: "About", action: "orderFrontStandardAboutPanel", key: ""}
        "-"
        {title: "Preferences", action: preferences, key: ","}
        "-"
        {title: "Hide #{name}", action: "hide", key: "h"}
        {title: "Hide Others", action: "hideOtherApplications", key: "h", modifiers:["Alternate", "Command"]}
        {title: "Show all", action: "unhideAllApplications", key: "h"}
        "-"
        {title: "Quit #{name}", action: "terminate", key: "q"}
      ]
    "File": [
        {title:"New",  action:"newDocument", key:"n"}
        {title:"Open", action:"openDocument", key:"o"}
        "-"
        {title:"Close", action:"performClose", key:"w"}
        {title:"Save...", action:"saveDocument", key:"s"}
        {title:"Save As...", action:"saveDocumentAs", key:""}
        "-"
        "WithSubMenus": [
          {title:"SubMenu 1", action: (-> console.log ("Submenu 1")), key:""}
          "FurtherSubMenus": [
            {title:"SubMenu 2.1", action: (-> console.log ("Submenu 2.1")), key:""}
            {title:"SubMenu 2.2", action: (-> console.log ("Submenu 2.2")), key:""}
          ]
          {title:"SubMenu 3", action: (-> console.log ("Submenu 3")), key:""}
        ]
        "-"
        {title:"Print...", action:"print", key:""}
      ]
    "Edit": [
        {title:"Undo",  action:"undo", key:"z"}
        {title:"Redo",  action:"redo", key:"Z"}
        "-"
        {title:"Cut",  action:"cut", key:"x"}
        {title:"Copy",  action:"copy", key:"c"}
        {title:"Paste",  action:"paste", key:"v"}
        {title:"Select All",  action:"selectAll", key:"a"}
      ]
    "Window": [
        {title:"Minimize",  action:"performMiniaturize", key:"m"}
        {title:"Zoom",  action:"performZoom", key:""}
        "-"
        {title:"Bring All to Front",  action:"arrangeInFront", key:""}
      ]
    "Help": [
        {title:"#{name} Help",  action:"showHelp", key:"m"}
      ]

  menu = app.addAppMenu(menuConfig)
  .init()

createStatusBar = (name, imagePath, app) ->
  menuConfig =
    "StatusMenu": [   # name not used
      "WithSubMenus": [
        {title:"SubMenu 1", action: (-> console.log ("Status Submenu 1")), key:""}
        "FurtherSubMenus": [
          {title:"SubMenu 2.1", action: (-> console.log ("Status Submenu 2.1")), key:""}
          {title:"SubMenu 2.2", action: (-> console.log ("Status Submenu 2.2")), key:""}
        ]
        {title:"SubMenu 3", action: (-> console.log ("Status Submenu 3")), key:""}
      ]
      {title: "Quit #{name}", action: "terminate", key: "q"}
    ]
  statusBar = app.addStatusBar(imagePath, menuConfig, name)
  .init()


#
# The actual Cocoa UI
#
secondWindow = (app, title, minValue, maxValue) ->
  window = app.addWindow "window2", title, ["Titled", "Resizable", "Miniaturizable", "Closable"]
  .cascadeTopLeftFromPoint 20, 20

  view = window.addMainView("view")
  .setBackgroundColor(0, 0, 0.5, 0.2)

  progress = window.addProgressIndicator("progress", 0, 10)
  view.addSubview progress
  view.setLayout("H:|-[progress(>=w)]-|", {w:200, h:50}, [progress])
  view.setLayout("V:|-[progress(>=h)]-|", {w:200, h:50}, [progress])


createUI = (title, app) ->
  # Create the window
  debug "Create UI"
  window = app.addWindow "mainWindow", title, ["Titled", "Resizable", "Miniaturizable", "Closable"]
  .cascadeTopLeftFromPoint 20, 20
  .onResize ->   debug "resized"
  .onMinimize -> debug "minimize"
  .onMaximize -> debug "maximize"
  .onClose ->    debug "close"
  .init()

  # define the main view
  mainview = window.addMainView("mainview")
  .setBackgroundColor(0.5, 0.5, 0.5, 0.4)

  # and all UI controls
  label = window.addLabel("label", "A Label")
  .setBackgroundColor(0.5, 0, 0, 0.4)

  ubi = true
  red = false
  checkbox1 = window.addCheckBox("checkbox1", "UBI")
  .setBackgroundColor(0.2, 0, 0.5, 0.4)
  .setState true
  .onClick -> debug "checkbox ubi=", (checkbox1.getState() == 1)
  .init()

  checkbox2 = window.addCheckBox("checkbox2", "Red")
  .setBackgroundColor(0.2, 0, 0.5, 0.4)
  .onClick -> debug "checkbox red=", (checkbox2.getState() == 1)
  .init()

  checkbox3 = window.addCheckBox("checkbox3", "Dummy")
  .setBackgroundColor(0.2, 0, 0.5, 0.4)
  .setEnabled false

  addButton = window.addButton("add", "Add")
  .onClick ->
    text = lorem({count:1, units:"paragraphs"})
    textview.appendText text, {font:"Calibri", size:16, \
                               face:(if (checkbox1.getState() == 1) then "ubi" else ""), \
                               color: (if (checkbox2.getState() == 1) then [0.8,0,0] else [0,0,0])}
    app.fireEvent "handleOk", true
  .init()

  clearButton = window.addButton("clear", "Clear")
  .onClick ->
    textview.clearText()
    app.fireEvent "handleCancel", {"a":42, b:false}
  .init()

  openButton = window.addButton("open", "Open")
  .onClick ->
    options =
      folder:"/Users/bernhard/Development"
      multipleSelection: true
      chooseFolders: true
      chooseFiles: true
      hiddenFiles: true
      title: "Test open"
      prompt: "Get it"
      message: "Select multiple files as you like"
    window.openDialog (selection) ->
      console.log selection
    , options
  .init()

  saveButton = window.addButton("save", "Save")
  .onClick ->
    options =
      folder:"/Users/bernhard/Development"
      chooseFiles: false
      hiddenFiles: true
      title: "Test save"
      prompt: "Store it"
      message: "Select target name and location"
    app.saveDialog (folder, filename) ->
      console.log folder, filename
    , options
  .init()

  quitButton = window.addButton("quit", "Quit")
  .onClick ->
    ret = criticalAlert("Attention", "Do you really want to quit?", ["Ok", "Cancel"])
    if ret == 0
      app.terminate()
  .init()

  # register the event for rpc
  app.on "progressWindow", (title, minValue, maxValue) ->
    secondWindow app, title, minValue, maxValue
  
  (nextwindowButton = window.addButton("nextwindow", "New Window"))
  .onClick ->
    app.fireEvent "manageProgress", {window:"window2", control:"progress"}, {window:"mainWindow", control:"nextwindow"}
  .init()

  textfield = window.addTextField("textfield", "TextField 1")
  .setBackgroundColor(0, 0.5, 0, 0.4)
  .onBeginEditing -> debug "textfield start editing"
  .onEndEditing -> debug "textfield end editing: #{textfield.getText()}"
  .init()

  image = window.addImage("image", "/Users/bernhard/Development/cocoa-ui/example/NodeCocoa.jpg")

  textview = window.addTextView("textview")
  .setBackgroundColor(1.0, 1.0, 0, 0.2)
  .onSelected -> debug textview.selectedRange()
  .onBeginEditing -> debug "textview start editing"
  .onEndEditing -> debug "textview end editing: #{textview.getText()}"
  .init()

  scrollview = window.addScrollView("scrollview", textview)
  textview.appendText lorem({count:2, units:"paragraphs"})

  choices = [ 'The quick', 'brown fox', 'jumps over', 'the lazy dog']
  radiobuttons = window.addRadioButtons("radio", choices)
  .setBackgroundColor(0, 0.5, 0.5, 0.8)
  .onSelect -> debug "#{radiobuttons.getSelected()}:#{choices[radiobuttons.getSelected()]}"
  .init()

  combobox = window.addComboBox("combobox", choices)
  .setEditable true
  .setText "(select)"
  .onSelected ->
    index = combobox.getSelectedIndex()
    debug "changed: #{index} = #{combobox.getValueAt(index)}"
  .onBeginEditing -> debug "combobox start editing"
  .onEndEditing -> debug "combobox end editing: #{combobox.getText()}"
  .init()

  label2 = window.addLabel("label2", "5")

  slider = window.addSlider("slider", 0, 10)
  .numTicks 11
  .snapToTicks true
  .setValue 5
  .onMoved -> label2.setText "" + slider.getValue()
  .init()

  progress = window.addProgressIndicator("spin")
  running = false
  startStop = window.addButton("startstop", "Start spin")
  .onClick ->
    if running
      progress.stop()
      running = false
      startStop.setTitle "Start spin"
    else
      progress.start()
      running = true
      startStop.setTitle "Stop spin"
  .init()

  # Add all UI controls to main view ...
  views = [label, nextwindowButton, openButton, saveButton, addButton, clearButton, quitButton, textfield, image,
           scrollview, radiobuttons, checkbox1, checkbox2, checkbox3, combobox, slider, label2, progress, startStop]
  mainview.addSubview v for v in views
  # ... define some metrics ...
  metrics = {h1:20, h2:30, h3:100, h4:640, h5:80, d:20, w1:120, w2:500, w3:100}
  # ... and layout the UI using tags from ui controls above in constraints
  constraints = [
    "H:|-[label(w1)]-[scrollview(>=w2)]-[quit(w3)]-|"
    "H:|-[textfield(w1)]"
    "H:|-[image(w1)]"
    "H:|-[radio(w1)]"
    "H:|-[label2(w1)]"
    "H:|-[slider(w1)]"
    "H:|-[combobox(w1)]"
    "H:|-[checkbox1(w1)]"
    "H:|-[checkbox2(w1)]"
    "H:|-[checkbox3(w1)]"
    "H:|-[spin(w1)]"
    "H:[startstop(w3)]-|"
    "H:[nextwindow(w3)]-|"
    "H:[open(w3)]-|"
    "H:[save(w3)]-|"
    "H:[add(w3)]-|"
    "H:[clear(w3)]-|"
    "V:|-[label(h1)]-(d)-[textfield(h3)]-(d)-[image(h3)]-(d)-[radio(h5)]-(d)-[label2(h1)]-(4)-[slider(h2)]-(d)-" +
      "[combobox(h1)]-(d)-[checkbox1(h1)]-(4)-[checkbox2(h1)]-(4)-[checkbox3(h1)]-(d)-[spin(h2)]"
    "V:[startstop(h2)]-[nextwindow(h2)]-[open(h2)]-[save(h2)]-[add(h2)]-[clear(h2)]-[quit(h2)]-|"
    "V:|-[scrollview(>=h4)]-|"
  ]
  mainview.setLayout(constraint, metrics, views) for constraint in constraints
  return app

exports.createUI = createUI
exports.createDefaultMenu = createDefaultMenu
exports. createStatusBar = createStatusBar
