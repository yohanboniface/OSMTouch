import QtQuick 2.2
import Ubuntu.Components 1.1
import '../Helpers.js' as Helpers

Page {
    id: page
    title: source.name;
    property var source;
    property var category;

    Column {
        id: container
        width: parent.width
        height: parent.height
    }

    readonly property var defaultTags: ['phone', 'website', 'wheelchair', 'internet_access']
    readonly property var templates: {
        'phone': 'PhoneRow.qml',
        'website': 'WebsiteRow.qml'
    }

    Component.onCompleted: {
        var tags = category.tags || defaultTags, tag, value;
        // We don't use an array as extraTags property, as tags.concat
        // will not consider it as an array (it's a ListModel it seems)
        if (category.extraTags) tags = tags.concat(category.extraTags.split(','));
        for (var i=0, l=tags.length; i<l; i++) {
            tag = tags[i];
            value = source.tags[tag];
            if (!value) continue;
            var row = Qt.createComponent(Qt.resolvedUrl(templates[tag] || "Row.qml"));
            row.createObject(container, {value: value, text: tag});
        }

    }

}
