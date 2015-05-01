import QtQuick 2.0
import QtLocation 5.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import QtQuick.XmlListModel 2.0
import QtQuick.LocalStorage 2.0
import "../models" as Models
import "./Helpers.js" as Helpers

Page {
    id: navPage
    title: i18n.tr("Navigate")
    visible: false

    property string navState: ""
    property real fromLon: 0.0
    property real fromLat: 0.0
    property real toLon: 0.0
    property real toLat: 0.0

    Models.SearchPlaceModel {
        id: searchModel
        onStatusChanged: {
            if (status === XmlListModel.Error) {
                httpFailedSearch.show();
            }
            if (status === XmlListModel.Ready && count === 0) {
                var place = "your search";
                if (navState === "startpoint") {
                    place = startPoint.text;
                } else if (navState === "endpoint") {
                    place = endPoint.text;
                }

                noResult.text = i18n.tr("Sorry, no result for ") + place;
                noResult.visible = true;
            } else {
                noResult.visible = false;
            }
        }
    }

    SplashComponent {
        id: httpFailedSearch
        objectName: "HTTPFailedSearch"
    }

    TextField {
        id: startPoint
        width: parent ? parent.width - units.gu(2) : undefined
        hasClearButton: true
        focus: true
        placeholderText: i18n.tr("Enter a place name to start from")
        primaryItem: Image {
            height: parent.height*0.5
            width: parent.height*0.5
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -units.gu(0.2)
            source: Helpers.getIcon("search")
        }
        onAccepted: {
            if (text) {
                navState = "startpoint"
                searchModel.searchString = text;
                searchModel.search();
                startPoint.focus = false
            }
        }
        // Indicator to show search activity
        ActivityIndicator {
            id: startSearchActivity
            anchors {
                right: startPoint.right
                rightMargin: units.gu(1)
                verticalCenter: startPoint.verticalCenter
            }
            running: (navState === "startpoint" && searchModel.status === XmlListModel.Loading)
        }
    }
    TextField {
        id: endPoint
        anchors.top: startPoint.bottom
        width: parent ? parent.width - units.gu(2) : undefined
        hasClearButton: true
        placeholderText: i18n.tr("Enter a place name to go to")
        primaryItem: Image {
            height: parent.height*0.5
            width: parent.height*0.5
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -units.gu(0.2)
            source: Helpers.getIcon("search")
        }
        onAccepted: {
            if (text) {
                navState = "endpoint"
                searchModel.searchString = text;
                searchModel.search();
                endPoint.focus = false
            }
        }
        // Indicator to show search activity
        ActivityIndicator {
            id: endSearchActivity
            anchors {
                right: endPoint.right
                rightMargin: units.gu(1)
                verticalCenter: endPoint.verticalCenter
            }
            running: (navState === "endpoint" && searchModel.status === XmlListModel.Loading)
        }
    }
    Button {
        id: carNavBtn
        text: i18n.tr("By Car")
        anchors.top: endPoint.bottom
        onClicked: {
            map.navigate(fromLat, fromLon, toLat, toLon, RouteQuery.CarTravel);
            map.goToLatLng(fromLat, fromLon);
            navPage.pageStack.pop();
        }
    }
// XXX: OSRM doesn't support these routing methods. :(
//    Button {
//        id: bikeNavBtn
//        text: i18n.tr("By Bike")
//        anchors.top: endPoint.bottom
//        anchors.left: carNavBtn.right
//        onClicked: {
//            map.navigate(fromlat, fromlon, tolat, tolon, RouteQuery.BicycleTravel);
//            map.goToLatLng(fromlat, fromlon);
//            navPage.pageStack.pop();
//        }
//    }
//    Button {
//        id: footNavBtn
//        text: i18n.tr("On Foot")
//        anchors.top: endPoint.bottom
//        anchors.left: bikeNavBtn.right
//        onClicked: {
//            map.navigate(fromlat, fromlon, tolat, tolon, RouteQuery.PedestrianTravel);
//            map.goToLatLng(fromlat, fromlon);
//            navPage.pageStack.pop();
//        }
//    }

    Rectangle {
        id: placeList;
        anchors {
            top: carNavBtn.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        visible: true
        Label {
            id: noResult
            objectName: "noResult"
            width: parent.width-units.gu(6)
            visible: false
            anchors.centerIn: parent
            fontSize: "medium"
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
        ListView {
            id: listView
            clip: true;
            anchors.fill: parent
            model: searchModel
            delegate: ListItem.Base {
                Label {
                    text: name
                    height: units.gu(5)
                    width: parent.width-units.gu(2)
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                onClicked: {
                    if (navState == "startpoint") {
                        console.debug("Start point", name, lat, lng);
                        startPoint.text = name;
                        startPoint.color = "green";
                        fromLat = lat;
                        fromLon = lng;
                        searchModel.clear()
                    } else if (navState == "endpoint") {
                        console.debug("End point", name, lat, lng);
                        endPoint.text = name;
                        endPoint.color = "green";
                        toLat = lat;
                        toLon = lng;
                        searchModel.clear()
                    }

                    navState = "";
                }
            }
            Scrollbar {
                flickableItem: listView;
                align: Qt.AlignTrailing;
            }
        }
    }
}
