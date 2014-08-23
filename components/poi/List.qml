import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import "Categories.js" as Categories
import "../Helpers.js" as Helpers



Page {
    id: poiComponent
    visible: false

    title: i18n.tr("Nearby")

    Component.onCompleted: {
        Categories.data.forEach(function(category) {
            poiModel.append(category);
        })
    }

    onVisibleChanged: {
        map.visible = !visible
    }

    ListModel {
        id: poiModel
    }

    Column {
        width: parent.width
        height: parent.height

        Component {
            id: sectionHeading
            ListItem.Header {
                text: section
            }
        }
        ListView {
            id: categoryList
            model: poiModel

            width: parent.width
            height: parent.height
            anchors { left: parent.left; right: parent.right}
            clip: true

            section.property: "theme"
            section.criteria: ViewSection.FullString
            section.labelPositioning: ViewSection.InlineLabels
            section.delegate: sectionHeading
            delegate: ListItem.Standard {
                id: poiItem
                text: label
                progression: true
                onClicked: {
                    map.resetPoi(model);
                    poiComponent.pageStack.pop();
                }

            }
            Scrollbar {
                flickableItem: categoryList
            }
        }
    }
}
