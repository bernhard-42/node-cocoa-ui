cd example
rm -fr CocoaUiDemo.app/
../bin/createStandaloneApp.sh CocoaUiDemo com.betaocean CocoaUiDemo.icns app.coffee ui.coffee package.json NodeCocoa*
cd ..
open example/CocoaUiDemo.app/