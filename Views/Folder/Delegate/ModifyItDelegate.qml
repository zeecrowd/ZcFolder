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

