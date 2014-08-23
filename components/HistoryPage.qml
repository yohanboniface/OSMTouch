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

    Component.onCompleted: {
        History.init();
    }

    ListModel {
        id: historyModel
    }

    ListView {
        id: listView
        clip: true;
        anchors.fill: parent
        model: historyModel
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
                stack.pop();
            }
        }
        Scrollbar {
            flickableItem: listView;
            align: Qt.AlignTrailing;
        }
    }

    function onPressed () {
        historyPage.reset();
    }

}
