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



    SplashScreen
    {
        id : splashScreenId
        width : parent.width
        height: parent.height
    }

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

                        if (file.cast.status === "new")
                        {
                            toBeDeleted.push(file.cast.name);
                        }

                        /*
                        ** SetDatas : lockedBy
                        */
                        var lockedBy = lockedActivityItems.getItem(file.cast.name,"");
                        var objectData = Tools.parseDatas(lockedBy)
                        objectData.lockedBy = lockedBy
                        file.cast.datas = JSON.stringify(objectData);
                    })

                    Tools.forEachInArray(toBeDeleted, function (x)
                    {
                        documentFolder.removeFileDescriptor(x);
                    })



                    loaderFolderView.item.setModel(documentFolder.files);
                    splashScreenId.height = 0;
                    splashScreenId.width = 0;
                    splashScreenId.visible = false;
                }
            }

            onImportFileToLocalFolderCompleted :
            {
                var fileDescriptor = Presenter.instance.fileDescriptorToUpload[fileName];

                Tools.setPropertyinListModel(uploadingFiles,"status","Uploading",function (x) { return x.name === fileName });
                Presenter.instance.decrementUploadRunning();
                Presenter.instance.startUpload(fileDescriptor,"");
            }

            onFileUploaded :
            {



                Presenter.instance.uploadFinished(fileName);

                // close the upload view
                if (uploadingFiles.count === 0)
                {
                    loaderUploadView.height = 0
                }
            }

            onFileDownloaded :
            {
                Presenter.instance.downloadFinished();
                var result = Tools.findInListModel(documentFolder.files, function(x)
                {return x.cast.name === fileName});

                if (result === null || result === undefined)
                    return;

                if (Presenter.instance.fileStatus[result.cast.name] === "open")
                {
                    Presenter.instance.fileStatus[result.cast.name] = null;
                    documentFolder.openFileWithDefaultApplication(result.cast);
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
                    mainView.refreshFiles();
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
            }



        }


    }

    SplitView
    {
        anchors.fill: parent
        orientation: Qt.Vertical

        Component
        {
            id : handleDelegateDelegate
            Rectangle
            {
                height : 10
                color :  styleData.hovered ? "grey" :  "lightgrey"
            }
        }

        handleDelegate : handleDelegateDelegate

        Loader
        {
            id : loaderFolderView
            source : "FolderGridView.qml"
            Layout.fillHeight : true

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
    {
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

    function lockFile(fileName)
    {
        lockedActivityItems.setItem(fileName,mainView.context.nickname)
    }

    function unlockFile(fileName)
    {
        lockedActivityItems.deleteItem(fileName)
    }

    function haveTheRighToModify(filename)
    {
        if (mainView.context.affiliation >= 3)
            return true;

        var lockedBy = lockedActivityItems.getItem(filename,"")

        if (lockedBy === null || lockedBy === undefined || lockedBy === "")
            return true;

        if (filename === mainView.context.nickname)
        {
            return true;
        }

        return false;
    }

//    function synchronizeSelectedFiles(file)
//    {
//        Tools.forEachInObjectList( documentFolder.files, function(x)
//        {
//            if (x.cast.isSelected)
//            {
//                synchronize(x.cast)
//            }
//        })
//    }

    function cancelUpload(fileName)
    {
        Presenter.instance.uploadFinished(fileName)
    }

    function restartUpload(fileName,path)
    {
        var file = Presenter.instance.fileDescriptorToUpload[fileName];
        if (file === null || file === undefined)
            return;

        Presenter.instance.startUpload(file.cast,path);
    }

//    function synchronize(file)
//    {

//        if (file.status === "upload")
//        {
//            console.log(">> synchronize " + file.name)

//            if (!mainView.haveTheRighToModify(file.name))
//                return;

//            Presenter.instance.startUpload(file.cast,"");
//        }
//        else if (file.status === "download")
//        {
//            Presenter.instance.startDownload(file);
//        }

//    }

    function openFile(file)
    {
        if (file.status === "")
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

    function putFilesOnTheCloud(fileUrls)
    {
        // open the uploadView
        if (loaderUploadView.height === 0)
        {
            loaderUploadView.height = 200
        }

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



}
