/**
* Copyright (c) 2010-2014 "Jabber Bees"
*
* This file is part of the ZcFolder application for the Zeecrowd platform.
*
* Zeecrowd is an online collaboration platform [http://www.zeecrowd.com]
*
* ZcFolder is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.5
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.4

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
            lockImage.iconSource = "qrc:/ZcCloud/Resources/lock.png"
            lockImage.tooltip = "Unlock File"
            lbLockedBy.text = "  " + dataObject.lockedBy;
            return;
        }

        lockImage.iconSource = "qrc:/ZcCloud/Resources/unlock.png"
        lockImage.tooltip = "Lock File"
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

        ToolButton
        {
            height: 40
            width: 40

            anchors.verticalCenter: parent.verticalCenter


            action : Action
            {
            id : lockImage

            onTriggered :
            {
                var datasObject = Tools.parseDatas(item.datas);

                /*
                ** I can't unlocked a file than i modify
                */
                if ( datasObject.modifyingBy === mainView.context.nickname )
                    return;

                // lock or unlock
                if (datasObject.lockedBy === undefined ||
                        datasObject.lockedBy === "" ||
                        datasObject.lockedBy === null )
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
//        Image
//        {
//            id : lockImage
//            height      : 40
//            width       : 40

//            anchors.verticalCenter: parent.verticalCenter

//            MouseArea
//            {
//                anchors.fill: parent
//                enabled     : parent.visible

//                onClicked:
//                {
//                    var datasObject = Tools.parseDatas(item.datas);

//                    /*
//                    ** I can't unlocked a file than i modify
//                    */
//                    if ( datasObject.modifyingBy === mainView.context.nickname )
//                        return;

//                    // lock or unlock
//                    if (datasObject.lockedBy === undefined ||
//                            datasObject.lockedBy === "" ||
//                            datasObject.lockedBy === null )
//                    {
//                        mainView.lockFile(item.name);
//                    }
//                    else
//                    {
//                        if (mainView.haveTheRighToLockUnlock(item.name))
//                        {
//                            mainView.unlockFile(item.name);
//                        }
//                    }
//                }
//            }
//        }

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
