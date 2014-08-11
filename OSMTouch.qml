import QtQuick 2.2
import QtLocation 5.0
import QtPositioning 5.2
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import QtQuick.XmlListModel 2.0
import Ubuntu.Components.ListItems 1.0 as ListItem
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

    Page {
        id: mapPage
        visible: true
        title: ' '
        property double lastKnownLat
        property double lastKnownLng

        head.backAction: Action {
            id: clearPoiAction
            iconName: 'back'
            text: i18n.tr("Clear")
            onTriggered: {
                poiPlaceModel.clear();
            }
            visible: poiPlaceModel.isActive()
        }

        head.actions: [
            Action {
                id: locateAction
                text: i18n.tr("Where am I")
                iconSource: Qt.resolvedUrl("icons/locate.svg")
                onTriggered: {
                    map.goToPosition();
                }
            },
            Action {
                id: searchPlaceAction
                text: i18n.tr("Search a place")
                iconName: 'search'
                onTriggered: {
                    PopupUtils.open(searchManager);
                }
            },
            Action {
                id: selectPoiAction
                iconName: 'location'
                text: i18n.tr("Points of interest nearby")
                onTriggered: {
                    PopupUtils.open(poiManager);
                }
            }
        ]

        Map {
            id: map
            zoomLevel: 5
            center {
                latitude: 49.2
                longitude: 4.1003
            }
            StateSaver.properties: "zoomLevel,center.latitude,center.longitude"
            property var poiBbox
            readonly property int minPoiZoom: 15

            plugin: Plugin {
                id: osmPlugin
                preferred: ["osm"]
                PluginParameter { name: "useragent"; value: mapView.applicationName }
            }

            // Enable pinch gestures to zoom in and out
            gesture.flickDeceleration: 3000
            gesture.enabled: true
            anchors.fill: parent

            Component.onCompleted: {
                src.update();
            }

            Models.PoiModel {
                id: poiPlaceModel
                onStatusChanged: {
                    if(status == XmlListModel.Error) {
                        httpFailedSearch.show();
                    }
                    if (status == XmlListModel.Loading) {
                        mapLoading.show();
                    } else {
                        mapLoading.hide();
                    }
                }
            }

            Components.SplashComponent {
                id: approximateGeolocation
                objectName: "approximateGeolocation"
                message: i18n.tr("No GPS available. Position is approximate.")
            }

            Components.SplashComponent {
                id: httpFailedSearch
                objectName: "HTTPFailedSearch"
            }

            Components.MapLoading {
                id: mapLoading
            }

            MapItemView {
                id: poiView

                model: poiPlaceModel
                delegate: MapQuickItem {
                    id: poiItem

                    coordinate.latitude: lat
                    coordinate.longitude: lng

                    anchorPoint.x: poiImage.width * 0.5
                    anchorPoint.y: poiImage.height
                    visible: map.zoomLevel >= map.minPoiZoom

                    sourceItem: Image {
                        id: poiImage

                        source: "icons/marker.svg"
                        width: 42
                        height: 54
                        z: 9
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                placePopover.update(model);
                                placePopover.show();
                                poiImage.state = "HIGHLIGHT"
                            }
                        }
                        states: State {
                            name: "HIGHLIGHT"
                            when: placePopover.visible && placePopover.osm_id === model.osm_id
                            PropertyChanges {target: poiImage; source: "icons/marker_hl.svg"}
                        }
                    }
                }
            }

            MapCircle {
                id: positionAccuracy
                z: 1
                visible: !!center.latitude
                opacity: 0.3
                radius: 100
                color: 'blue'
                border.width: 0
            }

            MapQuickItem {
                id: userPosition
                z: 10
                visible: !!coordinate.latitude
                anchorPoint.x: centerPositionImage.width/2
                anchorPoint.y: centerPositionImage.height/2
                sourceItem: Image {
                    id: centerPositionImage
                    width: 24
                    height: 24
                    source: "icons/position.svg"
                }
            }

            MapQuickItem {
                id: searchMarker
                z: 11
                visible: !!coordinate.latitude
                anchorPoint.x: searchMarkerImage.width/2
                anchorPoint.y: searchMarkerImage.height
                sourceItem: Image {
                    id: searchMarkerImage
                    width: 42
                    height: 54
                    source: "icons/marker_neutral.svg"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            searchMarker.coordinate.latitude = 0;
                            searchMarker.coordinate.longitude = 0;
                        }
                    }
                }
            }

            onCenterChanged: {
                if ((poiPlaceModel.clause && !poiBbox) || (poiBbox && !isInBbox(poiBbox))) {
                    fetchPoi();
                }
            }

            function isInBbox (other) {
                var b = bbox();
                return !(b.left < other.left || b.top > other.top || b.right > other.right || b.bottom < other.bottom);
            }

            function bbox () {
                var topLeft = map.toCoordinate(Qt.point(0, 0)),
                        bottomRight = map.toCoordinate(Qt.point(map.width, map.height)),
                        b = {
                            top: topLeft.latitude,
                            left: topLeft.longitude,
                            bottom: bottomRight.latitude,
                            right: bottomRight.longitude
                        };
                return b;
            }

            function extendedBbox () {
                var b = bbox(),
                        w = b.right - b.left,
                        h = b.top - b.bottom;
                b.left = b.left - w;
                b.right = b.right + w;
                b.top = b.top + h;
                b.bottom = b.bottom - h;
                return b;
            }

            function toBboxString (b) {
                // Left, top, right, bottom
                b = b || bbox();
                return [b.left, b.top, b.right, b.bottom].join(",");
            }

            function toBboxStringLbrt (b) {
                // Left, bottom, right, top
                b = b || bbox();
                return [b.left, b.bottom, b.right, b.top].join(",");
            }

            function updateUserPosition (position) {
                userPosition.coordinate = position.coordinate;
                positionAccuracy.center = position.coordinate;
                if (position.horizontalAccuracyValid && position.horizontalAccuracy) {
                    positionAccuracy.radius = position.horizontalAccuracy;
                }
            }

            function resetPoi (clause, label) {
                poiPlaceModel.clause = clause;
                poiPlaceModel.label = label;
                map.zoomLevel = Math.max(map.zoomLevel, map.minPoiZoom)
                fetchPoi();
            }

            function fetchPoi () {
                if (zoomLevel >= map.minPoiZoom) {
                    poiBbox = extendedBbox();
                    poiPlaceModel.search(toBboxStringLbrt(poiBbox));
                }
            }

            function goToPosition () {
                src.update();
                if (src.position.latitudeValid && src.position.longitudeValid) {
                    var coord = src.position.coordinate;
                    map.center.latitude = coord.latitude;
                    map.center.longitude = coord.longitude;
                    map.updateUserPosition(src.position);
                    map.zoomLevel = Math.max(map.zoomLevel, 17);
                } else if (mapPage.lastKnownLat && mapPage.lastKnownLng) {
                    map.center.latitude = mapPage.lastKnownLat;
                    map.center.longitude = mapPage.lastKnownLng;
                    map.zoomLevel = Math.max(map.zoomLevel, 14);
                    approximateGeolocation.show();
                } else {
                    PopupUtils.open(dialog);
                }
            }
        }

        Rectangle {
            anchors {
                right: parent.right
                bottom: parent.bottom
            }
            height: units.gu(2)
            width: units.gu(22)
            opacity: 0.7
            Label {
                text: " © OpenStreetMap contributors"
                fontSize: "small"
            }
        }

        Components.PlacePopover {
            id: placePopover
        }

        PositionSource {
            id: src
            active: true
            updateInterval: 1000
            onPositionChanged: map.updateUserPosition(position)
        }

        Models.GeoIPModel {
            // TODO find a way to trigger call only at button click
            id: geoIP
            onStatusChanged: {
                if (status == XmlListModel.Ready && geoIP.get(0).city != "None") {
                    mapPage.lastKnownLng = geoIP.get(0).lng;
                    mapPage.lastKnownLat = geoIP.get(0).lat;
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

    Components.SearchSheet {
        id: searchManager
    }

    Components.PoiSheet {
        id: poiManager
    }
}
