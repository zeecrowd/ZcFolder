import QtQuick 2.5
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.4

import ZcClient 1.0 as Zc

ButtonStyle {
    id: style

    property int alignment: Text.AlignHCenter
    property color textColor: "black"

    label: Text {
        width: parent.width
        text: control.text
        font.pixelSize: Zc.AppStyleSheet.height(0.12)
        horizontalAlignment: alignment
        verticalAlignment: Text.AlignVCenter
        color: textColor
    }

    background: Rectangle {
        anchors.margins: -Zc.AppStyleSheet.width(0.08)
        color: control.pressed
            ? "#ccc"
            : control.focus || control.hovered
                ? "#eee"
                : "transparent"
    }
}
