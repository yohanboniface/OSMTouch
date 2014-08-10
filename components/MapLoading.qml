import QtQuick 2.0
import Ubuntu.Components 0.1

Rectangle {
    id: mapLoading
    width: parent.width
    height: units.gu(5)
    color: UbuntuColors.coolGrey
    visible: (opacity > 0.0)
    opacity: 0
    z:100
    anchors {
        top: parent.top
    }
    property string message: i18n.tr("Loading…")

    Label {
        id: label
        text: message
        anchors.centerIn: parent
        width: parent.width-units.gu(3)
        fontSize: "medium"
        color: UbuntuColors.orange
    }
    ActivityIndicator {
        id: loadActivity
        anchors {
            right: parent.right
            rightMargin: units.gu(1)
            verticalCenter: label.verticalCenter
        }
        running: true
    }
    NumberAnimation {
        id: hideLoader
        target: mapLoading
        properties: "opacity"
        from: mapLoading.opacity
        to: 0
        easing: UbuntuAnimation.StandardEasing
        duration: UbuntuAnimation.SleepyDuration
    }
    NumberAnimation {
        id: showLoader
        target: mapLoading
        properties: "opacity"
        from: 0
        to: 0.9
        easing: UbuntuAnimation.StandardEasing
        duration: UbuntuAnimation.BriskDuration
    }
    function show() {
        showLoader.start()
    }
    function hide() {
        hideLoader.start()
    }
}
