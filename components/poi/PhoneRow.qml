import '../Helpers.js' as Helpers

Row {
    onClicked: {
        var number = Helpers.cleanPhoneNumber(value);
        if (!number) {
            return;
        }
        Qt.openUrlExternally("tel:///" + number);
    }
}
