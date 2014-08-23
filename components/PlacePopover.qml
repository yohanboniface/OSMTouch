import QtQuick 2.0
//import QtLocation 5.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
//import QtQuick.XmlListModel 2.0
import Ubuntu.Components.ListItems 0.1 as ListItem
import "Helpers.js" as Helpers

Popover {
    id: mapPopover
    property string osm_id

    Column {
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }
        ListItem.Standard {
            Label {
                id: mapPopoverName
                text: ""
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: units.gu(1)
                }
            }
        }
        ListItem.SingleValue {
            id: mapPopoverCuisine
            text: "Cuisine"
            value: ""
            visible: !!value
        }
        ListItem.SingleValue {
            id: mapPopoverPhone
            text: "Phone"
            value: ""
            visible: !!value
            onClicked: {
                var number = Helpers.cleanPhoneNumber(value);
                if (!number) {
                    return;
                }
                Qt.openUrlExternally("tel:///" + number);
            }
        }
        ListItem.SingleValue {
            id: mapPopoverWeb
            text: "Website"
            value: ""
            visible: !!value
            onClicked: {
                if (value.indexOf("://") === -1) {
                    Qt.openUrlExternally("http://" + value)
                    return
                }
                Qt.openUrlExternally(value)
            }
        }
        ListItem.SingleValue {
            id: mapPopoverWheelchair
            text: "Wheelchair access"
            value: ""
            visible: !!value
        }
        ListItem.SingleControl {
            id: mapPopoverZoomButton
            property double lat;
            property double lng;
            height: units.gu(8)
            control: Button {
                anchors {
                    margins: units.gu(1)
                    fill: parent
                }
                text: "Zoom to"
                onClicked: {
                    mapPopover.hide();
                    map.center.latitude = mapPopoverZoomButton.lat;
                    map.center.longitude = mapPopoverZoomButton.lng;
                    map.zoomLevel = 18;
                }
            }
        }
    }

    function update(model) {
        osm_id = model.osm_id;
        mapPopoverName.text = model.name || poiPlaceModel.label;
        mapPopoverPhone.value = model.phone || "";
        mapPopoverWeb.value = model.website || "";
        mapPopoverCuisine.value = model.cuisine || "";
        mapPopoverWheelchair.value = model.wheelchair || "";
        mapPopoverZoomButton.lat = model.lat;
        mapPopoverZoomButton.lng = model.lng;
        mapPopoverZoomButton.control.pressed = false;
    }

}
