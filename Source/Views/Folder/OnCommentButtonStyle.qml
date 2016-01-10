import QtQuick 2.5
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.4

import ZcClient 1.0 as Zc

ButtonStyle {
    id: style

	property color textColor: "black"
	
    label: Text {
        anchors.centerIn: parent
        font.capitalization: Font.AllUppercase
        text: control.text
        font.pixelSize: Zc.AppStyleSheet.height(0.12)
        horizontalAlignment: Text.AlignRight
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
