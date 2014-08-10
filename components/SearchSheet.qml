import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import QtQuick.XmlListModel 2.0
import "../models" as Models
import "./Helpers.js" as Helpers

Component {
    id: searchComponent

    DefaultSheet {
        id: searchSheet
        title: i18n.tr("Search")
        contentsHeight: parent.height

        Component.onCompleted: {
            searchLabel.forceActiveFocus();
        }

        onVisibleChanged: {
            map.visible = !visible
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

        container: Item {
            width: parent.width
            Rectangle {
                id: searchInput
                width:parent.width-units.gu(2)
                height:units.gu(5)
                anchors.horizontalCenter: parent.horizontalCenter
                color: "transparent"
                TextField {
                    id: searchLabel
                    anchors { left: parent.left; top: parent.top; right: parent.right }
                    height: parent.height
                    width: parent.width
                    hasClearButton: true
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
            }
            Rectangle {
                id: placeList;
                anchors.top: searchInput.bottom
                width: parent.width
                height: searchSheet.height-searchInput.height-units.gu(9.5)
                color: "transparent"
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
                            map.zoomLevel = 17;
                            map.center.latitude = lat;
                            map.center.longitude = lng;
                            searchMarker.coordinate.longitude = lng;
                            searchMarker.coordinate.latitude = lat;
                            PopupUtils.close(searchSheet);
                        }
                    }
                    Scrollbar {
                        flickableItem: listView;
                        align: Qt.AlignTrailing;
                    }
                }
            }

        }

    }
}
