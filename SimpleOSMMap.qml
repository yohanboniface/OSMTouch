import QtQuick 2.0
import QtLocation 5.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import "components"

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "com.ubuntu.developer.yohanboniface.simpleosmmap"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    automaticOrientation: true
    width: units.gu(100)
    height: units.gu(75)
    backgroundColor: "#444444"

    Page {

        Map {
            id: map
            zoomLevel: 10
            center {
                latitude: 49.2
                longitude: 4.1003
            }

            plugin: Plugin {
                preferred: ["osm"]
            }

            // Enable pinch gestures to zoom in and out
            gesture.flickDeceleration: 3000
            gesture.enabled: true
            width: parent.width
            height: parent.height
        }

        PositionSource {
            id: src
            active: true
//            onPositionChanged: {
                // center the map on the current position
//              map.center = position.coordinate
//            }
        }

        tools: ToolbarItems {
            ToolbarButton {
                action: Action {
                    text: i18n.tr("My position")
                    iconSource: Qt.resolvedUrl("icons/locate_me.png")
                    onTriggered: {
                        src.update();
                        if (src.position.latitudeValid && src.position.longitudeValid) {
                            var coord = src.position.coordinate;
                            console.log("Coordinate:", coord.longitude, coord.latitude);
                        } else {
                            PopupUtils.open(dialog);
                        }
                    }
                }
            }
        }

        Component {
             id: dialog
             Dialog {
                 id: dialogue
                 title: i18n.tr("Error")
                 text: i18n.tr("Sorry, no location available. Please check your location settings.")
                 Button {
                     text: i18n.tr("OK, too bad…")
                     onClicked: PopupUtils.close(dialogue)
                 }
             }
        }
    }
}
