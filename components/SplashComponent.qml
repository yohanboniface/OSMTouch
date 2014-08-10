import QtQuick 2.0
import Ubuntu.Components 0.1

UbuntuShape {
    id: httpFailedSplash
    width: parent.width-units.gu(10)
    color: "#fff"
    visible: (opacity > 0.0)
    opacity: 0
    z:100
    anchors.centerIn: parent
    property string message: i18n.tr("Couldn't load data, please try later again!")

    Label {
        id: splashLabel
        text: message
        anchors.centerIn: parent
        fontSize: "medium"
        width: parent.width-units.gu(2)
        horizontalAlignment: Text.AlignHCenter
        color: UbuntuColors.orange
        wrapMode: Text.WordWrap
    }
    Timer {
        id: splashTimer
        interval: 2000
        repeat: false
        onTriggered: {
            hideSplashBox.start()
        }
    }
    NumberAnimation {
        id: hideSplashBox
        target: httpFailedSplash
        properties: "opacity"
        from: 0.8
        to: 0
        easing: UbuntuAnimation.StandardEasing
        duration: UbuntuAnimation.SleepyDuration
    }
    NumberAnimation {
        id: showSplashBox
        target: httpFailedSplash
        properties: "opacity"
        from: 0
        to: 0.8
        easing: UbuntuAnimation.StandardEasing
        duration: UbuntuAnimation.BriskDuration
    }
    function show() {
        showSplashBox.start()
        splashTimer.start()
    }
}
