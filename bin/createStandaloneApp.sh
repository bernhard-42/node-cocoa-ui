#!/bin/bash

function usage {
  echo "$(basename $0) <AppName> <budle-id-prefix> <icns File> <start file> [<app file 1> <app file 2> ...]" 
  exit 1
}

if [ -z "$4" ]; then
  usage
fi

APP_NAME="$1"
shift
PREFIX="$1"
shift
ICNS_FILE="$1"
shift
START="$1"
shift

if [ -d "${APP_NAME}.app" ]; then
  echo "Error: app ${APP_NAME} already exists"
  exit 1
fi

# create OSX App folder hierarchy
mkdir -p "${APP_NAME}.app/Contents/MacOS"
mkdir -p "${APP_NAME}.app/Contents/Resources"

# create start shell script
cat <<EOF1 > "${APP_NAME}.app/Contents/MacOS/$APP_NAME"
#!/bin/sh
export PATH="\$PATH:/usr/local/bin"
cd "\$(dirname \$0)/../Resources"
exec coffee "${START}" > "/tmp/${APP_NAME}App.log" 2>&1
EOF1
chmod a+x "${APP_NAME}.app/Contents/MacOS/$APP_NAME" 

# create Info.plist
cat <<EOF2 > "${APP_NAME}.app/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleGetInfoString</key>
  <string>${APP_NAME}</string>
  <key>CFBundleExecutable</key>
  <string>${APP_NAME}</string>
  <key>CFBundleIdentifier</key>
  <string>${PREFIX}.${APP_NAME}</string>
  <key>CFBundleName</key>
  <string>${APP_NAME}</string>
  <key>CFBundleIconFile</key>
  <string>${ICNS_FILE}</string>
  <key>CFBundleShortVersionString</key>
  <string>0.01</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>IFMajorVersion</key>
  <integer>0</integer>
  <key>IFMinorVersion</key>
  <integer>1</integer>
</dict>
</plist>
EOF2

# create cococ-ui node-modules folder
mkdir -p "${APP_NAME}.app/Contents/Resources/node_modules/cocoa-ui"
cp -r "$(dirname $0)/../lib" "${APP_NAME}.app/Contents/Resources/node_modules/cocoa-ui"

# copy all app files to Resources
cp $START $ICNS_FILE $@ "${APP_NAME}.app/Contents/Resources"

# get missing node_modules
cd "${APP_NAME}.app/Contents/Resources"
if [ -f package.json ]; then
  npm install
fi