import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import QtQuick.XmlListModel 2.0
import QtQuick.LocalStorage 2.0
import "../models" as Models
import "./Helpers.js" as Helpers
import "./History.js" as History

Page {
    id: searchPage
    title: i18n.tr("Search")
    visible: false

    Component.onCompleted: {
        History.init();
    }

    onVisibleChanged: {
        if (visible) searchLabel.forceActiveFocus();
    }

    Models.SearchPlaceModel {
        id: searchModel
        onStatusChanged: {
            if (status === XmlListModel.Error) {
                httpFailedSearch.show();
            }
            if (status === XmlListModel.Ready && count === 0) {
                noResult.text = i18n.tr("Sorry, no result for ") + searchLabel.text;
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

    head.contents: TextField {
        id: searchLabel
        anchors.right: parent.right
        hasClearButton: true
        focus: true
        placeholderText: i18n.tr("Enter a place name")
        primaryItem: Image {
            height: parent.height*0.5
            width: parent.height*0.5
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -units.gu(0.2)
            source: Helpers.getIcon("search")
        }
        onAccepted: {
            if (text) {
                searchModel.searchString = text;
                searchModel.search();
                searchLabel.focus = false
            }
        }
        // Indicator to show search activity
        ActivityIndicator {
            id: searchActivity
            anchors {
                right: searchLabel.right
                rightMargin: units.gu(6)
                verticalCenter: searchLabel.verticalCenter
            }
            running: searchModel.status === XmlListModel.Loading
        }
    }

    Rectangle {
        id: placeList;
        anchors {
            top: parent.top
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
                    History.push(name, lat, lng);
                    map.goToLatLng(lat, lng);
                    searchMarker.coordinate.longitude = lng;
                    searchMarker.coordinate.latitude = lat;
                    searchPage.pageStack.pop();
                }
            }
            Scrollbar {
                flickableItem: listView;
                align: Qt.AlignTrailing;
            }
        }
    }
}
