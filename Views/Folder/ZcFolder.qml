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
                mainView.state = "import"
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
        ,
        Action {
            id: refreshAction
            shortcut: "F5"
            iconSource: "qrc:/ZcCloud/Resources/synchronize.png"
            tooltip : "Synchronize all\nselected files"
            onTriggered:
            {
                mainView.synchronizeSelectedFiles();
            }
        }
        ,
        Action {
            id: iconAction
            iconSource: "qrc:/ZcCloud/Resources/tile.png"
            onTriggered:
            {
                loader.item.clean()
                loader.source = "";
               loader.source = "FolderGridIconView.qml"
               loader.item.setModel(documentFolder.files);
            }
        }
        ,
        Action {
            id: listAction
            iconSource: "qrc:/ZcCloud/Resources/list.png"
            onTriggered:
            {
                loader.item.clean()
                loader.source = "";
               loader.source = "FolderGridView.qml"
               loader.item.setModel(documentFolder.files);
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

                        var lockedBy = lockedActivityItems.getItem(file.cast.name,"");


                        if (lockedBy !== null && lockedBy !== "" && lockedBy !== undefined)
                        {
                            var objectData = {}
                            objectData.lockedBy = lockedBy
                            file.cast.datas = JSON.stringify(objectData);
                        }
                    })

                    Tools.forEachInArray(toBeDeleted, function (x)
                    {
                        documentFolder.removeFileDescriptor(x);
                    })



                    loader.item.setModel(documentFolder.files);
                    splashScreenId.height = 0;
                    splashScreenId.width = 0;
                    splashScreenId.visible = false;
                }
            }

            onImportFileToLocalFolderCompleted :
            {
                var result = Tools.findInListModel(documentFolder.files, function(x)
                {return x.cast.name === fileName});

                if (result === null || result === undefined)
                    return;

                documentFolder.uploadFile(result);
            }

            onFileUploaded :
            {
                Presenter.instance.uploadFinished();

                var result = Tools.findInListModel(documentFolder.files, function(x)
                {return x.cast.name === fileName});


                if (result === null || result === undefined)
                    return;

                notifySender.sendMessage("","{ sender : \"" + mainView.context.nickname + "\", action : \"added\" , fileName : \"" + fileName + "\" , size : " +  result.size + " , lastModified : \"" + result.timeStamp + "\" }");
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
                notifySender.sendMessage("","{ sender : \"" + mainView.context.nickname + "\", action : \"deleted\" , fileName : \"" + fileName + "\"}");
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
                var o = eval("(" + message.body +")" );

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
                        if (o.sender !== mainView.context.nickname)
                        {
                            var fd = documentFolder.getFileDescriptor(o.fileName,true);
                            fd.setRemoteInfo(o.size,new Date(o.lastModified));
                            fd.status = "download";
                        }
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
                   mainView.refreshFiles();
               }

               onErrorOccured :
               {
                   console.log(">> ERRROR " + error + " " + errorCause  + " " + errorMessage)
               }
             }

             onItemChanged :
             {
                 console.log(">> item changed ")
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
                 console.log(">> onItemDeleted "  +idItem)

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

    function lockFile(fileName)
    {
        console.log(">> lockFile ")
        lockedActivityItems.setItem(fileName,mainView.context.nickname)
    }

    function unlockFile(fileName)
    {
        console.log(">> lunockFile ")
        lockedActivityItems.deleteItem(fileName)
    }

    Loader
    {
        id : loader
        anchors.fill : parent
        source : "FolderGridView.qml"
    }

    FileDialog
    {
        id: fileDialog
        nameFilters: ["All Files(*.*)"]

        onAccepted:
        {
            if ( state == "import" )
            {
                importFile(fileDialog.fileUrls);
            }
//            else
//            {
//                exportFile(fileDialog.folder);
//            }
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

    function synchronizeSelectedFiles(file)
    {
        Tools.forEachInObjectList( documentFolder.files, function(x)
        {
            if (x.cast.isSelected)
            {
                synchronize(x.cast)
            }
        })
    }

    function synchronize(file)
    {

        if (file.status === "upload")
        {
            console.log(">> synchronize " + file.name)

            if (!mainView.haveTheRighToModify(file.name))
                return;

            Presenter.instance.startUpload(file,"");
        }
        else if (file.status === "download")
        {
            Presenter.instance.startDownload(file);
        }

    }

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

    function importFile(fileUrls)
    {
        var fds = [];
        for ( var i = 0 ; i < fileUrls.length ; i ++)
        {
            var fd = documentFolder.addFileDescriptorFromFile(fileUrls[i]);

            console.log(">> importfile " + fd.name)

            if (!mainView.haveTheRighToModify(fd.name))
                continue;

            if (fd !== null)
            {
                console.log(">> fileName " + fd.name)

                var fdo = {}
                fdo.fileDescriptor =fd;
                fdo.url = fileUrls[i];
                fds.push(fdo);
                fd.queryProgress = 1;
            }
        }

        Tools.forEachInArray(fds, function (x)
        {
            Presenter.instance.startUpload(x.fileDescriptor,x.url);
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
                console.log(">> tobeDeleted " + file.cast.name)

                if (mainView.haveTheRighToModify(file.cast.name))
                {
                    toBeDeleted.push(file);
                }
            }
        })

        Tools.forEachInArray(toBeDeleted, function (x)
        {

            documentFolder.deleteFile(x.cast);
        })
    }

    function refreshFiles()
	{
        documentFolder.loadFiles();
        documentFolder.loadRemoteFiles(documentFolderQueryStatus);
    }

    Timer
    {
        id                      : timerId

        interval : 1000
        repeat   : true
        running : true;

        onTriggered:
        {
//            if (needRefresh)
//            {
//                needRefresh = false;
//                refreshFiles()
//            }
        }
    }
}
