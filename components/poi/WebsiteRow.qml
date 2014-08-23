import '../Helpers.js' as Helpers

Row {
    onClicked: {
        if (value.indexOf("://") === -1) {
            value = "http://" + value;
        }
        Qt.openUrlExternally(value)
    }
}
