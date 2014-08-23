import QtQuick 2.2
import Ubuntu.Components 1.1
import "components" as Components
import "models" as Models
import "components/Helpers.js" as Helpers


/*!
    \brief MainView with a Label and Button elements.
*/

MainView {

    id: mapView
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "me.yohanboniface.osmtouch"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true
    useDeprecatedToolbar: false
    width: units.gu(50)
    height: units.gu(75)
    backgroundColor: "#fff"

    property alias map: mapPage.map

    Components.MapPage {
        id: mapPage
    }

    PageStack {
        id: stack
        Component.onCompleted: stack.push(mapPage)
    }

    Components.SearchPage {
        id: searchPage
    }

    Components.PoiPage {
        id: poiPage
    }
}
