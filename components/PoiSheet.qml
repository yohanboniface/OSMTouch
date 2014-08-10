import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "Categories.js" as Categories
import "Helpers.js" as Helpers



Component {
    id: poiComponent

    DefaultSheet {
        id: poiSheet

        title: i18n.tr("Nearby")
        contentsHeight: parent.height

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

        container: Column {
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
                        map.resetPoi(clause, label);
                        PopupUtils.close(poiSheet);
                    }

                }
                Scrollbar {
                    flickableItem: categoryList
                }
            }
        }
    }
}
