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

//import QtQuick 2.0
//import "../Tools.js" as Tools
//FileTextDelegate
//{
//    text : ""
//    isBusy : item != null && item !== undefined ?  item.busy : false
//    position : index

//    onClicked :
//    {
//        mainView.iModifyTheFile(item.name)
//        documentFolder.downloadFile(item.cast,".modify")
//    }
//    //notifyPressed: true

//    function updateDelegate()
//    {
//        if (item === undefined ||item === null)
//            return;

//        // TODO : an admin can abort a pending modification

//        /*
//        ** Can't modify a file already in modification
//        */
//        var dataObject = Tools.parseDatas(item.cast.datas)
//        if (dataObject.modifyingBy !== undefined &&
//                dataObject.modifyingBy !== null &&
//                dataObject.modifyingBy !== "")
//        {
//            text = dataObject.modifyingBy
//            return;
//        }

//        /*
//        ** Can modify a file if itsn't locked or i lock it
//        */

//        if (dataObject.lockedBy === undefined ||
//                dataObject.lockedBy === null ||
//                dataObject.lockedBy === "" ||
//                dataObject.lockedBy === mainView.context.nickname)
//        {
//            text = "<a href=\" \">Modify</a>"
//            return;
//        }

//        text = ""
//    }

//    Component.onCompleted:
//    {
//        updateDelegate();
//        item.cast.datasChanged.connect(updateDelegate)
//    }



//}

