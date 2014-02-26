import QtQuick 2.0

Image
{
    width: 40
    height: 40

    Component.onCompleted:
    {
        if (item.status === "" ||item.status === null || item.status === "upload")
        {
            source = "image://icons/" + "file:///" + documentFolder.localPath + item.cast.name
        }
        else
        {
            source = "image://icons/" + "file:///" + item.cast.name
        }

    }

    MouseArea
    {
        anchors.fill: parent

        onClicked: mainView.openFile(item)
    }
}
