import QtQuick 2.0
import QtQuick.Controls 1.0

Rectangle
{
    height      : 40
    width       : 150

    Row
    {
        anchors.fill: parent

        spacing: 10

        Image
        {
            height: 40
            width: 40

            anchors.verticalCenter: parent.verticalCenter

            visible    : item.status !== "" && !item.busy
            source : item.status === "upload" ? "qrc:/ZcCloud/Resources/export.png" : "qrc:/ZcCloud/Resources/import.png"

            MouseArea
            {
                anchors.fill: parent
                enabled     : parent.visible

                onClicked:
                {
                    mainView.synchronize(item)
                }
            }
        }
        Label
        {
            visible : item.status === "upload"

            textFormat: Text.RichText
            height : 25
            width : 125
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize              : 16
            text : "<a href=\" \">Cancel</a>"
            onLinkActivated:
            {
                documentFolder.removeLocalFile(item.name)
            }
        }
    }
}
