import QtQuick 2.0
import QtQuick.Controls 1.0
import "../Tools.js" as Tools

Item
{
    id : delegateLock

    /*
    ** Et lock/unlock image from datas.lockedBy
    */
    function setImageLock()
    {
        if (item === undefined ||item === null)
            return;

        var dataObject = Tools.parseDatas(item.cast.datas)
        if (dataObject.lockedBy !== undefined &&  dataObject.lockedBy !== null && dataObject.lockedBy !== "")
        {
            lockImage.source = "qrc:/ZcCloud/Resources/lock.png"
            return;
        }

        lockImage.source = "qrc:/ZcCloud/Resources/unlock.png"
    }

    /*
    ** Change lock image when datas changed
    */
    Component.onCompleted:
    {
        setImageLock();
        item.cast.datasChanged.connect(setImageLock)
    }

    height      : 25
    width       : 25

    Image
    {
        id : lockImage
        anchors.fill: parent


        MouseArea
        {
            anchors.fill: parent
            enabled     : parent.visible

            onClicked:
            {
                // Lock or unlock only have the right to do this
                if (!mainView.haveTheRighToModify(item.name))
                    return;

                var datasObject = Tools.parseDatas(item.datas);

                // lock or unlock
                if (datasObject.lockedBy === undefined || datasObject.lockedBy === "" || datasObject.lockedBy === null )
                {
                    mainView.lockFile(item.name);
                }
                else
                {
                    mainView.unlockFile(item.name);
                }
            }
        }
    }
}
