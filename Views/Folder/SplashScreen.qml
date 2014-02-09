import QtQuick 2.0
import QtQuick.Controls 1.0

Rectangle
{
    anchors.fill: parent
    color : "grey"
    opacity : 0.5

    Label
    {
        anchors.centerIn: parent
        font.pixelSize:  40;
        color : "white"
        text : "Loading ..."
    }
}

