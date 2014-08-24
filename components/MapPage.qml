import QtQuick 2.2
import QtLocation 5.0
import QtPositioning 5.2
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import QtQuick.XmlListModel 2.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import QtQuick.LocalStorage 2.0
import "../models" as Models
import "Helpers.js" as Helpers
import "History.js" as History
import "poi" as Poi

PageWithBottomEdge {
        id: mapPage
        visible: true
        title: poiPlaceModel.label || 'Map'
        property double lastKnownLat
        property double lastKnownLng
        property alias map: map
        property alias category: poiPlaceModel.category

        head.backAction: Action {
            id: clearPoiAction
            iconName: 'back'
            text: i18n.tr("Clear")
            onTriggered: {
                poiPlaceModel.purge();
            }
            visible: poiPlaceModel.active
        }

        head.actions: [
            Action {
                id: searchPlaceAction
                text: i18n.tr("Search a place")
                iconName: 'search'
                onTriggered: {
                    stack.push(searchPage);
                }
            },
            Action {
                id: locateAction
                text: i18n.tr("Where am I")
                iconSource: Qt.resolvedUrl("../icons/locate.svg")
                onTriggered: {
                    map.goToPosition();
                }
            },
            Action {
                id: selectPoiAction
                iconSource: Qt.resolvedUrl("../icons/nearby.svg")
                text: i18n.tr("Points of interest nearby")
                onTriggered: {
                    stack.push(poiPage);
                }
            }
        ]

        Map {
            id: map
            zoomLevel: 5
            center {
                latitude: 51
                longitude: 2
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
                onError: {
                    httpFailedSearch.show();
                    mapLoading.hide();
                }
                onLoading: {
                    mapLoading.show();
                }
                onDone: {
                    mapLoading.hide();
                }
            }

            SplashComponent {
                id: approximateGeolocation
                objectName: "approximateGeolocation"
                message: i18n.tr("No GPS available. Position is approximate.")
            }

            SplashComponent {
                id: httpFailedSearch
                objectName: "HTTPFailedSearch"
            }

            MapLoading {
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

                        source: "../icons/marker.svg"
                        width: 42
                        height: 54
                        z: 9
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                stack.push(Qt.resolvedUrl("./poi/View.qml"),{source: model, category: category});
                            }
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
                    source: "../icons/position.svg"
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
                    source: "../icons/marker_neutral.svg"
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

            function toBboxStringBltr (b) {
                // Bottom, left, top, right
                b = b || bbox();
                return [b.bottom, b.left, b.top, b.right].join(",");
            }

            function updateUserPosition (position) {
                userPosition.coordinate = position.coordinate;
                positionAccuracy.center = position.coordinate;
                if (position.horizontalAccuracyValid && position.horizontalAccuracy) {
                    positionAccuracy.radius = position.horizontalAccuracy;
                }
            }

            function resetPoi (model) {
                poiPlaceModel.category = model;
                map.zoomLevel = Math.max(map.zoomLevel, map.minPoiZoom)
                fetchPoi();
            }

            function fetchPoi () {
                if (zoomLevel >= map.minPoiZoom) {
                    poiBbox = extendedBbox();
                    poiPlaceModel.search(toBboxStringBltr(poiBbox));
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
                    PopupUtils.open(noPositionDialog);
                }
            }

            function goToLatLng (lat, lng, zoom) {
                map.center.latitude = lat;
                map.center.longitude = lng;
                map.zoomLevel = zoom || 17;
            }

            function addSearchMarker (lat, lng) {
                console.log('adding search marker', lat, lng)
                searchMarker.coordinate.latitude = lat;
                searchMarker.coordinate.longitude = lng;
                console.log('is visible', searchMarker.visible, searchMarker.coordinate.latitude)
            }
        }

        Rectangle {
            anchors {
                right: parent.right
                bottom: parent.bottom
            }
            height: units.gu(2)
            width: units.gu(25)
            opacity: 0.7
            Label {
                text: " © OpenStreetMap contributors"
                fontSize: "small"
            }
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
             id: noPositionDialog
             Dialog {
                 id: dialog
                 title: i18n.tr("Error")
                 text: i18n.tr("Sorry, no location available. Please check your location settings.")
                 Button {
                     text: i18n.tr("OK, too bad…")
                     onClicked: PopupUtils.close(dialog)
                 }
             }
        }

        bottomEdgePageComponent: HistoryPage {}
        bottomEdgeTitle: i18n.tr("Recent")

        onBottomEdgeExposedAreaChanged: {
            var margin = 50;
            if (!bottomEdgePage) return;
            if (bottomEdgeExposedHeight < margin) {
                bottomEdgePage.unsetCurrentIndex();
                return;
            }

            var index = bottomEdgePage.indexAt(50, bottomEdgeExposedHeight - margin);
            if (index < 3) {
                bottomEdgePage.currentIndex = index;
            } else {
                bottomEdgePage.unsetCurrentIndex();
            }
        }

        onBottomEdgeReleased: {
            if (bottomEdgePage.currentIndex < 3) {
                bottomEdgePage.activateCurrentIndex();
            }
            bottomEdgePage.unsetCurrentIndex();
        }

        onBottomEdgePressed: {
            bottomEdgePage.onPressed();
        }

        onBottomEdgeDismissed: {
            if (bottomEdgePage) bottomEdgePage.unsetCurrentIndex();
        }

        onBottomEdgeExpanded: {
            bottomEdgePage.unsetCurrentIndex();
        }

    }
