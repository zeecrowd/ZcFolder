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
        console.log(">> setImageLock ")
        if (item === undefined ||item === null)
            return;

        var dataObject = Tools.parseDatas(item.cast.datas)
        if (dataObject.lockedBy !== undefined &&  dataObject.lockedBy !== null && dataObject.lockedBy !== "")
        {
            lockImage.source = "qrc:/ZcCloud/Resources/lock.png"
            lbLockedBy.text = "  " + dataObject.lockedBy;
            return;
        }

        lockImage.source = "qrc:/ZcCloud/Resources/unlock.png"
        lbLockedBy.text = "";
    }

    /*
    ** Change lock image when datas changed
    */
    Component.onCompleted:
    {
        setImageLock();
        item.cast.datasChanged.connect(setImageLock)
    }

    height      : 40
    width       : 150

    Row
    {
        anchors.fill: parent

        Image
        {
            id : lockImage
            height      : 25
            width       : 25

            anchors.verticalCenter: parent.verticalCenter

            MouseArea
            {
                anchors.fill: parent
                enabled     : parent.visible

                onClicked:
                {
                    var datasObject = Tools.parseDatas(item.datas);

                    /*
                    ** I can't unlocked a file than i modify
                    */
                    console.log(">> datasObject.modifyingBy " + datasObject.modifyingBy)
                    console.log(">> datasObject.modifyingBy " + mainView.context.nickname)
                    if ( datasObject.modifyingBy === mainView.context.nickname )
                        return;

                    // lock or unlock
                    if (datasObject.lockedBy === undefined || datasObject.lockedBy === "" || datasObject.lockedBy === null )
                    {
                        mainView.lockFile(item.name);
                    }
                    else
                    {
                        if (mainView.haveTheRighToLockUnlock(item.name))
                        {
                            mainView.unlockFile(item.name);
                        }
                    }
                }
            }
        }

        Label
        {
            id : lbLockedBy
            height : 25
            width : 125
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize              : 16
        }
    }
}
