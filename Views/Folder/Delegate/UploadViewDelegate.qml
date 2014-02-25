import QtQuick 2.0
import QtQuick.Controls 1.0

Rectangle
{
    height : 20
    width : parent.width
    color : index % 2 ? "lightgrey" : "white"

    Row
    {
        anchors.fill: parent
        Label
        {
            id :lbStatus
            height : 20 ;
            width : 200 ;
            text: status ;
            color : "black";
            font.pixelSize:  16
        }

        Label
        {
            height : 20 ;
            anchors
            {
                left : lbStatus.right
                right : parent.right
            }

            text: name ;
            color : "black";
            font.pixelSize:  16
        }
    }

    ProgressBar
    {
        anchors.fill: parent
        visible : progress > 0
        opacity: 0.5

        height : parent.height
        width  : parent.width

        minimumValue: 0
        maximumValue: 100
        value       : progress
    }

}
