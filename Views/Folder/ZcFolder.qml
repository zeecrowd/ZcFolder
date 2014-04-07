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

import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.0

import "Tools.js" as Tools
import "ZcFolderPresenter.js" as Presenter

import ZcClient 1.0

ZcAppView
{
    id : mainView

    anchors.fill : parent

    toolBarActions : [
        Action {
            id: closeAction
            shortcut: "Ctrl+X"
            iconSource: "qrc:/ZcCloud/Resources/close.png"
            tooltip : "Close Aplication"
            onTriggered:
            {
                mainView.close();
            }
        },
        Action {
            id: importAction
            shortcut: "Ctrl+I"
            iconSource: "qrc:/ZcCloud/Resources/export.png"
            tooltip : "Push on the cloud"
            onTriggered:
            {
                mainView.state = "putOnCloud"
                fileDialog.selectMultiple = true;
                fileDialog.selectFolder = false
                fileDialog.open()
            }
        }
        ,
        Action {
            id: exportAction
            shortcut: "Ctrl+E"
            iconSource: "qrc:/ZcCloud/Resources/folder.png"
            tooltip : "Open local folder"
            onTriggered:
            {
                mainView.state = "export"
                exportFile();
                documentFolder.openLocalPath();
            }
        }
        ,
        Action {
            id: deleteAction
            shortcut: "Ctrl+D"
            iconSource: "qrc:/ZcCloud/Resources/bin.png"
            tooltip : "Delete File"
            onTriggered:
            {
                mainView.deleteSelectedFiles();
            }
        }
        //        ,
        //        Action {
        //            id: refreshAction
        //            shortcut: "F5"
        //            iconSource: "qrc:/ZcCloud/Resources/synchronize.png"
        //            tooltip : "Synchronize all\nselected files"
        //            onTriggered:
        //            {
        //                mainView.synchronizeSelectedFiles();
        //            }
        //        }
        ,
        Action {
            id: iconAction
            iconSource: "qrc:/ZcCloud/Resources/tile.png"
            onTriggered:
            {
                loaderFolderView.source = "";
                loaderFolderView.source = "FolderGridIconView.qml"
                loaderFolderView.item.setModel(documentFolder.files);
            }
        }
        ,
        Action {
            id: listAction
            iconSource: "qrc:/ZcCloud/Resources/list.png"
            onTriggered:
            {
                loaderFolderView.source = "";
                loaderFolderView.source = "FolderGridView.qml"
                loaderFolderView.item.setModel(documentFolder.files);
            }
        }

    ]

    property bool  needRefresh : false

    ZcCrowdActivity
    {
        id : activity

        ZcCrowdDocumentFolder
        {
            id   : documentFolder
            name : "Test"
            
            ZcQueryStatus
            {
                id : documentFolderQueryStatus

                onErrorOccured :
                {
                    console.log(">> ERRROR OCCURED")
                }

                onCompleted :
                {
                    var toBeDeleted = [];

                    Tools.forEachInObjectList( documentFolder.files, function(file)
                    {

                        /*
                        ** No longer exist on the server
                        */
                        if (file.cast.status === "new")
                        {
                            toBeDeleted.push(file.cast.name);
                        }

                        /*
                        ** SetDatas : lockedBy
                        */
                        var lockedBy = lockedActivityItems.getItem(file.cast.name,"");
                        //var modifyingBy = modifiersActivityItems.getItem(file.cast.name,"");
                        var objectData = Tools.parseDatas(lockedBy)
                        objectData.lockedBy = lockedBy
                        //objectData.modifyingBy = modifyingBy
                        file.cast.datas = JSON.stringify(objectData);
                    })

                    Tools.forEachInArray(toBeDeleted, function (x)
                    {
                        documentFolder.removeFileDescriptor(x);
                    })


                    loaderFolderView.item.setModel(documentFolder.files);

                    /*
                    ** Restart pending upload
                    */
                    var uploadFilePending = documentFolder.getFilePathFromDirectory(".upload");

                    Tools.forEachInArray(uploadFilePending, function (x)
                    {
                        openUploadView();
                        var completePath = documentFolder.localPath + ".upload/" + x;
                        var fd = documentFolder.createFileDescriptorFromFile(completePath);
                        if (fd !== null)
                        {
                            Presenter.instance.startUpload(fd,"")
                        }
                    });

                }
            }

            onImportFileToLocalFolderCompleted :
            {
                // import a file to the .upload directory finished
                if (localFilePath.indexOf(".upload") !== -1)
                {

                    var fileDescriptor = Presenter.instance.fileDescriptorToUpload[fileName];

                    Tools.setPropertyinListModel(uploadingFiles,"status","Uploading",function (x) { return x.name === fileName });
                    Presenter.instance.decrementUploadRunning();
                    Presenter.instance.startUpload(fileDescriptor,"");
                    return;
                }
            }

            onFileUploaded :
            {

                Presenter.instance.uploadFinished(fileName,true);

                // close the upload view
                closeUploadViewIfNeeded()
            }

            onFileDownloaded :
            {
                /*
                ** downloadFile to read it or to modify it
                */

                Presenter.instance.downloadFinished();

                // file dowloaded to modify it
                // then add it to the list if doens't exist
//                if (localFilePath.indexOf(".modify") !== -1)
//                {

//                }
                if (Presenter.instance.fileStatus[fileName] === "open")
                {
                   Presenter.instance.fileStatus[fileName] = null
                   Qt.openUrlExternally(localFilePath)
                }
            }
            onFileDeleted :
            {
                notifySender.sendMessage("","{ \"sender\" : \"" + mainView.context.nickname + "\", \"action\" : \"deleted\" , \"fileName\" : \"" + fileName + "\"}");
                // file no longer exist .. then ubnlock it
                mainView.unlockFile(fileName);
            }
        }

        onStarted:
        {
            lockedActivityItems.loadItems(
                        lockedActivityItemsQueryStatus);
        }

        ZcMessageListener
        {
            id      : notifyListener
            subject : "notify"

            onMessageReceived :
            {
                var o = JSON.parse(message.body);

                if ( o !==null )
                {

                    appNotification.blink();
                    if (!mainView.isCurrentView)
                    {
                        appNotification.incrementNotification();
                    }

                    if ( o.action === "deleted" )
                    {
                        documentFolder.removeFileDescriptor(o.fileName)
                        if (o.sender !== mainView.context.nickname)
                        {
                            documentFolder.removeLocalFile(o.fileName)
                        }
                    }
                    else if (o.action === "added")
                    {
                        var fd = documentFolder.getFileDescriptor(o.fileName,true);
                        fd.setRemoteInfo(o.size,new Date(o.lastModified));
                        fd.status = "download";
                    }
                }

            }
        }
        ZcMessageSender
        {
            id      : notifySender
            subject : "notify"
        }

        /*
        ** Contains all the files lockers
        */
        ZcCrowdActivityItems
        {
            id         : lockedActivityItems
            name       : "FilesLocked"
            persistent : true

            ZcQueryStatus
            {
                id : lockedActivityItemsQueryStatus

                onCompleted :
                {
                    documentFolder.ensureLocalPathExists();
                    documentFolder.ensureLocalPathExists(".upload");
                    //documentFolder.ensureLocalPathExists(".modify");
                    mainView.refreshFiles();

                    splashScreenId.height = 0;
                    splashScreenId.width = 0;
                    splashScreenId.visible = false;

//                    modifiersActivityItems.loadItems(
//                                modifiersActivityItemsQueryStatus);
                }

                onErrorOccured :
                {
                    console.log(">> ERRROR " + error + " " + errorCause  + " " + errorMessage)
                }
            }

            onItemChanged :
            {
                var objectFound = Tools.findInListModel(documentFolder.files, function(x)
                {return x.cast.name === idItem});

                if (objectFound !== null)
                {
                    var objectDatas = Tools.parseDatas(objectFound.cast.datas);
                    objectDatas.lockedBy = lockedActivityItems.getItem(idItem,"");
                    objectFound.cast.datas = JSON.stringify(objectDatas)
                }

                // Restart a blocking uploading File
                //                var pendingUploadFile = Tools.findInListModel(uploadingFiles, function(x)
                //                {return x.name === idItem});

                //                if (pendingUploadFile !== null)
                //                {
                //                    if (pendingUploadFile.status !== "Uploading")
                //                    {
                //                        restartUpload(pendingUploadFile.name,pendingUploadFile.localPath)
                //                    }
                //                }
            }

            onItemDeleted :
            {

                var objectFound = Tools.findInListModel(documentFolder.files, function(x)
                {return x.cast.name === idItem});

                if (objectFound !== null)
                {
                    var objectDatas = Tools.parseDatas(objectFound.cast.datas);
                    objectDatas.lockedBy = "";
                    objectFound.cast.datas = JSON.stringify(objectDatas)
                }

                // Restart a blocking uploading File
                //                var pendingUploadFile = Tools.findInListModel(uploadingFiles, function(x)
                //                {return x.name === idItem});

                //                if (pendingUploadFile !== null)
                //                {
                //                    if (pendingUploadFile.status !== "Uploading")
                //                    {
                //                        restartUpload(pendingUploadFile.name,pendingUploadFile.localPath)
                //                    }
                //                }

            }



        }

        /*
        ** Contains all the files modifiers
        */
//        ZcCrowdActivityItems
//        {
//            id         : modifiersActivityItems
//            name       : "FilesModifiers"
//            persistent : true

//            ZcQueryStatus
//            {
//                id : modifiersActivityItemsQueryStatus

//                onCompleted :
//                {
//                    documentFolder.ensureLocalPathExists();
//                    documentFolder.ensureLocalPathExists(".upload");
//                    //documentFolder.ensureLocalPathExists(".modify");
//                    mainView.refreshFiles();
//                }

//                onErrorOccured :
//                {
//                    console.log(">> ERRROR " + error + " " + errorCause  + " " + errorMessage)
//                }
//            }

//            function updateModifiers(fileName,modifier)
//            {
//                console.log(">> updateModiyiers " + fileName + " " + modifier)
//                var objectFound = Tools.findInListModel(documentFolder.files, function(x)
//                {return x.cast.name === fileName});

//                console.log(">> object found " + objectFound)
//                if (objectFound !== null)
//                {
//                    var objectDatas = Tools.parseDatas(objectFound.cast.datas);
//                    //objectDatas.modifyingBy = modifier;
//                    objectFound.cast.datas = JSON.stringify(objectDatas)
//                }

//            }

//            onItemChanged :
//            {
//                updateModifiers(idItem,modifiersActivityItems.getItem(idItem,""));
//            }

//            onItemDeleted :
//            {
//                updateModifiers(idItem,"");
//            }



//        }

    }

    SplitView
    {
        anchors.fill: parent
        orientation: Qt.Vertical

        Component
        {
            id : handleDelegateVertical
            Rectangle
            {
                height : 10
                color :  styleData.hovered ? "grey" :  "lightgrey"
            }
        }

        Component
        {
            id : handleDelegateHorizontal
            Rectangle
            {
                width : 10
                color :  styleData.hovered ? "grey" :  "lightgrey"
            }
        }

        handleDelegate : handleDelegateVertical

        Loader
        {

            Layout.fillHeight : true
            Rectangle
            {
                anchors.fill: parent
                color : "white"
            }

            id : loaderFolderView
            source : "FolderGridView.qml"
            Layout.fillWidth : true
        }



        Loader
        {
            id : loaderUploadView
            height : 0

            source : "UploadStatusView.qml"

            onSourceChanged:
            {
                item.setModel(uploadingFiles);
            }
        }
    }

    FileDialog
    {
        id: fileDialog
        nameFilters: ["All Files(*.*)"]

        onAccepted:
        {
            if ( state == "putOnCloud" )
            {
                putFilesOnTheCloud(fileDialog.fileUrls);
            }
        }
    }

    ZcAppNotification
    {
        id : appNotification
    }

    onLoaded :
    {
        Presenter.instance.documentFolder = documentFolder
        activity.start();
    }

    onClosed :
    {i
        activity.stop();
    }

    onIsCurrentViewChanged :
    {
        if (isCurrentView == true)
        {
            appNotification.resetNotification();
        }
    }

    ListModel
    {
        id : uploadingFiles
    }

    //    ListModel
    //    {
    //        id : modifyingFiles
    //    }

//    function  iModifyTheFile(fileName)
//    {
//        lockFile(fileName)
//        modifiersActivityItems.setItem(fileName,mainView.context.nickname)
//    }

    function lockFile(fileName)
    {
        lockedActivityItems.setItem(fileName,mainView.context.nickname)
    }

    function unlockFile(fileName)
    {
        lockedActivityItems.deleteItem(fileName)
    }

    function haveTheRighToLockUnlock(filename)
    {
        if (mainView.context.affiliation >= 3)
            return true;

        return haveTheRighToModify(filename);
    }

    function haveTheRighToModify(filename)
    {

        var lockedBy = lockedActivityItems.getItem(filename,"")

        if (lockedBy === null || lockedBy === undefined || lockedBy === "")
            return true;

        if (lockedBy === mainView.context.nickname)
        {
            return true;
        }

        return false;
    }

    function cancelUpload(fileName)
    {
        // false : no notification for all users
        Presenter.instance.uploadFinished(fileName,false)
        closeUploadViewIfNeeded()
    }

    function restartUpload(fileName,path)
    {
        var file = Presenter.instance.fileDescriptorToUpload[fileName];
        if (file === null || file === undefined)
            return;

        Presenter.instance.startUpload(file.cast,path);
    }

    function openFile(file)
    {
        // TODO : reduct the real Status
        if (file.status !== "download")
        {
            documentFolder.openFileWithDefaultApplication(file.cast);
        }
        else
        {
             Presenter.instance.fileStatus[file.cast.name] = "open"
            //    documentFolder.downloadFile(file.cast)
            Presenter.instance.startDownload(file);
        }
    }

    function closeUploadViewIfNeeded()
    {
        if (uploadingFiles.count === 0)
        {
            loaderUploadView.height = 0
        }
    }

    function openUploadView()
    {
        if (loaderUploadView.height === 0)
        {
            loaderUploadView.height = 200
        }
    }

    function putFilesOnTheCloud(fileUrls)
    {
        openUploadView()

        var fds = [];
        for ( var i = 0 ; i < fileUrls.length ; i ++)
        {
            var fd = documentFolder.createFileDescriptorFromFile(fileUrls[i]);


            if (fd !== null)
            {
                var fdo = {}
                fdo.fileDescriptor =fd;
                fdo.url = fileUrls[i];
                fds.push(fdo);
                fd.queryProgress = 1;
            }
        }

        Tools.forEachInArray(fds, function (x)
        {
            Presenter.instance.startUpload(x.fileDescriptor.cast,x.url);
        });
    }

    function exportFile()
    {
        Tools.forEachInObjectList( documentFolder.files, function(x)
        {
            if (x.cast.isSelected)
            {
                if (x.cast.status !== "")
                {
                    x.queryProgress = 1;
                    Presenter.instance.startDownload(x.cast);
                    //documentFolder.downloadFile(x.cast)
                }
            }
        })
    }

    function synchronize(file)
      {

          if (file.status === "upload")
          {
              if (!mainView.haveTheRighToModify(file.name))
                  return;

              openUploadView()

              Presenter.instance.startUpload(file.cast,documentFolder.localPath + file.name);
          }
          else if (file.status === "download")
          {
              Presenter.instance.startDownload(file);
          }

      }


    function deleteSelectedFiles()
    {
        var toBeDeleted = [];

        Tools.forEachInObjectList( documentFolder.files, function(file)
        {
            if (file.cast.isSelected)
            {

                if (mainView.haveTheRighToModify(file.cast.name))
                {
                    toBeDeleted.push(file);
                }
            }
        })

        Tools.forEachInArray(toBeDeleted, function (x)
        {
            mainView.lockFile(x.cast.name);
            documentFolder.deleteFile(x.cast);
        })
    }

    function refreshFiles()
    {
        documentFolder.loadFiles();
        documentFolder.loadRemoteFiles(documentFolderQueryStatus);
    }

    SplashScreen
    {
        id : splashScreenId
        width : parent.width
        height: parent.height
    }


}
