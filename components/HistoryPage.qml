import QtQuick 2.2
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import QtQuick.XmlListModel 2.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import QtQuick.LocalStorage 2.0
import "Helpers.js" as Helpers
import "History.js" as History

Page {
    id: historyPage

    property alias currentIndex: listView.currentIndex

    title: i18n.tr('Recent places')
    anchors.fill: parent

    function reset() {
        historyModel.clear();
        var items = History.pull(), item;
        for(var i=0; i < items.length; i++) {
            item = items.item(i);
            historyModel.append({
                name: item.name,
                lat: item.lat,
                lng: item.lng
            });
        }
    }

    function unsetCurrentIndex () {
        if (listView.count) listView.currentIndex = -1;
    }

    Component.onCompleted: {
        History.init();
    }

    ListModel {
        id: historyModel
    }

    Component {
        id: highlight
        Rectangle {
            width: 180
            height: 40
            color: "lightgrey"
            y: listView.currentItem ? listView.currentItem.y : 0
        }
    }

    Label {
        id: emptyHistory
        objectName: "emptyHistory"
        width: parent.width-units.gu(6)
        text: i18n.tr('Nothing in the history yet')
        visible: !listView.count
        anchors.centerIn: parent
        fontSize: "medium"
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }

    ListView {
        id: listView
        clip: true;
        anchors.fill: parent
        model: historyModel
        highlight: highlight
        currentIndex: -1
        delegate: ListItem.Base {
            Label {
                text: name
                height: units.gu(5)
                width: parent.width-units.gu(2)
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
            onClicked: {
                map.goToLatLng(lat, lng);
                stack.pop();
            }
        }
        Scrollbar {
            flickableItem: listView;
            align: Qt.AlignTrailing;
        }
    }

    function activateCurrentIndex () {
        if (currentIndex === -1) return;
        var place = historyModel.get(currentIndex);
        map.goToLatLng(place.lat, place.lng);
    }

    function onPressed () {
        historyPage.reset();
    }

    function indexAt (x, y) {
        return listView.indexAt(x, y);
    }
}
