import QtQuick 2.0

Rectangle
{
    height      : 25
    width       : 25
    color       : item != null && item !== undefined && item.busy ? "lightgrey" : (index % 2 ? "#FFF2B7" : "white")
    Image
    {
        anchors.fill: parent
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
}
