import QtQuick 2.5
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.4

import ZcClient 1.0 as Zc

BusyIndicatorStyle {
    id: style

    indicator: MouseArea {
        visible: control.running
        anchors.fill: parent

        Text {
            anchors.bottom: image.top
            anchors.bottomMargin: Zc.AppStyleSheet.height(0.08)
            anchors.horizontalCenter: parent.horizontalCenter
            color: "grey"
            text: control.title
        }

        Image {
            id: image

            property int steps: 0

            anchors.centerIn: parent
            width: Zc.AppStyleSheet.width(0.3)
            height: Zc.AppStyleSheet.width(0.3)
            source: "../Resources/busy-indicator.png"
            rotation: 30*steps

            NumberAnimation on steps {
                running: true
                from: 0
                to: 12
                loops: Animation.Infinite
                duration: 6000
            }
        }

        /*Button {
            anchors.top: image.bottom
            anchors.topMargin: Zc.AppStyleSheet.height(0.08)
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Cancel")
            visible : control.cancellable
            onClicked: control.running = false
        }*/
    }
}
