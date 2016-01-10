import QtQuick 2.5
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.2


Rectangle {
    property int count
    property int plusSignAfter: 99
    property string plusSign: "+"

    color: "blue"
    radius: width/2
    visible: count > 0

    Text {
        text: count < plusSignAfter ? count : plusSign
        font.pixelSize: parent.width*0.6
        font.bold: true
        color: "white"
        anchors.centerIn: parent
        visible: parent.visible
    }
}
