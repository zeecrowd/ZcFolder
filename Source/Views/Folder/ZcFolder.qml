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
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2

import "../../Components" as FolderComponents
import "Tools.js" as Tools

import ZcClient 1.0 as Zc

Zc.AppView
{
    id : mainView

    anchors.fill : parent

    menuActions :
        [
        Action {
            id: close2Action
            shortcut: "Ctrl+X"
            text:  "Close ZcFolder"
            onTriggered:
            {
                mainView.close();
            }
        },
        Action {
            id: addFile
            shortcut: "Ctrl+I"
            text:  "Add files"
            onTriggered:
            {
                mainView.state = "putOnCloud"
                fileDialog.selectMultiple = true;
                fileDialog.selectFolder = false;

                fileDialog.open()
            }
        }

    ]

    property bool  needRefresh : false
    property var fileStatus : ([])

    UploadManager
    {
        id : uploadManager
        documentFolder : documentFolderId
        lockedActivityItems : lockedActivityItemsId
        uploadingListFiles: uploadingFiles
        theNotifySender : notifySender
    }

    DownloadManager
    {
        id : downloadManager
        documentFolder : documentFolderId
    }

    Zc.SortFilterObjectListModel
    {
        id : sortFilterObjectListModel
    }

    Zc.JavaScriptSorter
    {
        id : javaScriptSorter

        function lessThan(left,right)
        {
            return left.name.toLowerCase() < right.name.toLowerCase();
        }
    }

    Zc.CrowdActivity
    {
        id : activity

        Zc.CrowdDocumentFolder
        {
            id   : documentFolderId
            name : "Test"
            
            Zc.QueryStatus
            {
                id : documentFolderQueryStatus

                onErrorOccured :
                {
                    console.log(">> ERRROR OCCURED")
                }

                onCompleted :
                {
                    var toBeDeleted = [];

                    Tools.forEachInObjectList( documentFolderId.files, function(file)
                    {

                        /*
                        ** No longer exist on the server
                        */
                        if (file.status === "new")
                        {
                            toBeDeleted.push(file.name);
                        }

                        /*
                        ** SetDatas : lockedBy
                        */
                        var lockedBy = lockedActivityItemsId.getItem(file.name,"");
                        //var modifyingBy = modifiersActivityItems.getItem(file.name,"");
                        var objectData = Tools.parseDatas(lockedBy)
                        objectData.lockedBy = lockedBy
                        //objectData.modifyingBy = modifyingBy
                        file.datas = JSON.stringify(objectData);
                    })

                    Tools.forEachInArray(toBeDeleted, function (x)
                    {
                        documentFolderId.removeFileDescriptor(x);
                    })


                    sortFilterObjectListModel.setModel(documentFolderId.files);
                    javaScriptSorter.qmlObjectSorter = javaScriptSorter;
                    sortFilterObjectListModel.setSorter(javaScriptSorter);

                    console.log(">> loaderFolderView.item.setModel " + sortFilterObjectListModel)
                    loaderFolderView.item.setModel(sortFilterObjectListModel);

                    /*
                    ** Restart pending upload
                    */
                    var uploadFilePending = documentFolderId.getFilePathFromDirectory(".upload");

                    Tools.forEachInArray(uploadFilePending, function (x)
                    {
                        openUploadView();
                        var completePath = documentFolderId.localPath + ".upload/" + x;
                        var fd = documentFolderId.createFileDescriptorFromFile(completePath);
                        if (fd !== null)
                        {
                            uploadManager.startUpload(fd,"")
                        }
                    });

                }
            }

            onImportFileToLocalFolderCompleted :
            {
                console.log(">> onImportFileToLocalFolderCompleted " + localFilePath)

                // import a file to the .upload directory finished
                if (localFilePath.indexOf(".upload") !== -1)
                {

                    var fileDescriptor = uploadManager.fileDescriptorToUpload[fileName];

                    Tools.setPropertyinListModel(uploadingFiles,"status","Uploading",function (x) { return x.name === fileName });
                    uploadManager.decrementUploadRunning();
                    uploadManager.startUpload(fileDescriptor,"");
                    return;
                }
            }

            onFileUploaded :
            {
                uploadManager.uploadFinished(fileName,true);
                appNotification.logEvent(0 /*Zc.AppNotification.Add*/,"File",fileName,"image://icons/" + "file:///" + fileName)

                // close the upload view
                closeUploadViewIfNeeded()
            }

            onFileDownloaded :
            {
                /*
                ** downloadFile to read it or to modify it
                */

                downloadManager.downloadFinished();

                // file dowloaded to modify it
                // then add it to the list if doens't exist
                //                if (localFilePath.indexOf(".modify") !== -1)
                //                {

                //                }
                if (fileStatus[fileName] === "open")
                {
                    fileStatus[fileName] = null
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
            console.log(">> onstarted " + mainView.context)
            commentsView.setAppContext(mainView.context)

            lockedActivityItemsId.loadItems(
                        lockedActivityItemsQueryStatus);
        }

        Zc.MessageListener
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
                        documentFolderId.removeFileDescriptor(o.fileName)
                        if (o.sender !== mainView.context.nickname)
                        {
                            documentFolderId.removeLocalFile(o.fileName)
                        }
                    }
                    else if (o.action === "added")
                    {
                        var fd = documentFolderId.getFileDescriptor(o.fileName,true);
                        fd.setRemoteInfo(o.size,new Date(o.lastModified));
                        fd.status = "download";
                    }
                }

            }
        }

        Zc.MessageSender
        {
            id      : notifySender
            subject : "notify"
        }

        /*
        ** Contains all the files lockers
        */
        Zc.CrowdActivityItems
        {
            id         : lockedActivityItemsId
            name       : "FilesLocked"
            persistent : true

            Zc.QueryStatus
            {
                id : lockedActivityItemsQueryStatus

                onCompleted :
                {
                    documentFolderId.ensureLocalPathExists();
                    documentFolderId.ensureLocalPathExists(".upload");
                    //documentFolderId.ensureLocalPathExists(".modify");
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
                var objectFound = Tools.findInListModel(documentFolderId.files, function(x)
                {return x.name === idItem});

                if (objectFound !== null)
                {
                    var objectDatas = Tools.parseDatas(objectFound.datas);
                    objectDatas.lockedBy = lockedActivityItemsId.getItem(idItem,"");
                    objectFound.datas = JSON.stringify(objectDatas)
                }

            }

            onItemDeleted :
            {

                var objectFound = Tools.findInListModel(documentFolderId.files, function(x)
                {return x.name === idItem});

                if (objectFound !== null)
                {
                    var objectDatas = Tools.parseDatas(objectFound.datas);
                    objectDatas.lockedBy = "";
                    objectFound.datas = JSON.stringify(objectDatas)
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
            source : parent.width < Zc.AppStyleSheet.width(6) ? "SmartFolderGridView.qml" : "FolderGridView.qml"
            Layout.fillWidth : true
            onLoaded: {
                loaderFolderView.item.setModel(sortFilterObjectListModel);
                //loaderFolderView.item.setModel(documentFolderId.files);

            }
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

    CommentsView {
        id : commentsView
        anchors.fill: parent
        visible : false
    }

    FileDialog {
        id : chooseFolderToDownload
        property var fileDescriptor : null
        selectFolder: true
        title : qsTr("Choose folder to download file")

        folder : shortcuts.documents

        onAccepted:
        {
            downloadManager.startDownload(fileDescriptor,folder)
        }
    }

    FileDialog
    {
        id: fileDialog
        nameFilters: ["All Files(*.*)"]

        folder : shortcuts.documents

        onAccepted:
        {
            if ( state == "putOnCloud" )
            {
                putFilesOnTheCloud(fileDialog.fileUrls);
            }
        }
    }

    Zc.AppNotification
    {
        id : appNotification
    }

    onLoaded :
    {
        //Presenter.instance.documentFolder = documentFolderId
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
        lockedActivityItemsId.setItem(fileName,mainView.context.nickname)
    }

    function unlockFile(fileName)
    {
        lockedActivityItemsId.deleteItem(fileName)
    }

    function haveTheRighToLockUnlock(filename)
    {
        if (mainView.context.affiliation >= 3)
            return true;

        return haveTheRighToModify(filename);
    }

    function haveTheRighToModify(filename)
    {

        var lockedBy = lockedActivityItemsId.getItem(filename,"")

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
        uploadManager.uploadFinished(fileName,false)
        closeUploadViewIfNeeded()
    }

    function restartUpload(fileName,path)
    {
        var file = uploadManager.fileDescriptorToUpload[fileName];
        if (file === null || file === undefined)
            return;

        uploadManager.startUpload(file,path);
    }

    function downloadFile(file)
    {
        chooseFolderToDownload.fileDescriptor = file;
        chooseFolderToDownload.open()
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

    // On passe dans le contecte les fichier à uploadé
    // si l'utilisateur est ok pour evvrider ceux qui existent
    // alors on les envoi à l'upload
    FolderComponents.Alert {
        id : alertFilesExist
        button1: "Ok"
        button2: "Cancel"
        message: qsTr("Files already exist.\nDo you want to override them?")
        onButton1Clicked: {
            openUploadView()
            Tools.forEachInArray(alertFilesExist.context, function (x)
            {
                uploadManager.startUpload(x.fileDescriptor,x.url);
            });
        }
        onButton2Clicked: {
            hide();
        }
    }

    // info sur un fichier
    FolderComponents.Alert {
        id : infoId
        button1: "Ok"
        //message: qsTr("Files already exist.\nDo you want to override them?")
        onButton1Clicked: {
            hide();
        }

        function showInfo(fileDescriptor)
        {
            message = "";
            message += fileDescriptor.name + "\n"
            message += qsTr("Size : " ) + fileDescriptor.remoteSizeKb + "kb\n"
            message += qsTr("Modified : " ) + fileDescriptor.remoteTimeStampLabel.replace(" GMT","") + "\n"
            var lby = lockedBy(fileDescriptor.datas);
            if (lby !== "")
                message += qsTr("Locked by : ") + lby + "\n"
            show();
        }
    }

    function isLocked(theDatats) {
        return lockedBy(theDatats) !== ""
    }

    function lockedBy(theDatats) {
        var dataObject = Tools.parseDatas(theDatats)
        if (dataObject.lockedBy !== undefined &&  dataObject.lockedBy !== null && dataObject.lockedBy !== "") {
            return dataObject.lockedBy;
        }
        else {
            return "";
        }
    }

    function showFileContextualMenu(item) {
        fileContextualMenu.fileDescriptor = item
        fileContextualMenu.show()
    }

    FolderComponents.ActionList {
        id: fileContextualMenu

        property var fileDescriptor : null
        property bool isLocked : false

        onFileDescriptorChanged: {
            if (fileDescriptor === null)
                return;
            console.log(">> fileDescriptor.datas " + fileDescriptor.datas)
            fileContextualMenu.isLocked = mainView.isLocked(fileDescriptor.datas)
        }

        Action {
            text: qsTr("Save")
            onTriggered: {
                mainView.downloadFile(fileContextualMenu.fileDescriptor)
            }
        }

        Action {
            text: qsTr("Save and Open")
            onTriggered: {
                // quand il sera downloadé alors on l'ouvrira
                fileStatus[fileContextualMenu.fileDescriptor.name] = "open"
                mainView.downloadFile(fileContextualMenu.fileDescriptor)
            }
        }

        Action {
            text: qsTr("Comments")
            onTriggered: {
                commentsView.fileDescriptor = fileContextualMenu.fileDescriptor;
                commentsView.visible = true;
            }
        }
        Action {
            id : lockUnlock
            text: fileContextualMenu.isLocked ? qsTr("Unlock") : qsTr("Lock")
            onTriggered: {
                if (fileContextualMenu.isLocked)
                  mainView.unlockFile(fileContextualMenu.fileDescriptor.name);
                else
                    mainView.lockFile(fileContextualMenu.fileDescriptor.name);
            }
        }


        Action {
            text: qsTr("Infos")
            onTriggered: {
                infoId.showInfo(fileContextualMenu.fileDescriptor)
            }
        }

        Action {
            text: qsTr("Delete")
            onTriggered: {
                mainView.deleteFile(fileContextualMenu.fileDescriptor)
            }
        }
    }

    function putFilesOnTheCloud(fileUrls)
    {
        var fds = [];
        var areExistingFilesOnCloud = false;
        for ( var i = 0 ; i < fileUrls.length ; i ++) {
            var fdo = uploadManager.createFileDescriptorFromFile(fileUrls[i]);
            if (fdo !== null) {
                fds.push(fdo);
                if (uploadManager.fileAlreadyExistOnCloud(fdo.fileDescriptor.name)) {
                    areExistingFilesOnCloud = true;
                }
            }
        }

        // Si il y a des fichiers qui vaient le même nom alors
        // on demande à l'utilisateur une confirmation
        // sinon on envoi à l'upload directement
        if (areExistingFilesOnCloud) {
            alertFilesExist.context = fds;
            alertFilesExist.show()
        } else {
            openUploadView();
            Tools.forEachInArray(fds, function (x)
            {
                uploadManager.startUpload(x.fileDescriptor,x.url);
            });
        }
    }

    function deleteSelectedFiles()
    {
        var toBeDeleted = [];

        Tools.forEachInObjectList( documentFolderId.files, function(file)
        {
            if (file.isSelected)
            {

                if (mainView.haveTheRighToModify(file.name))
                {
                    toBeDeleted.push(file);
                }
            }
        })

        Tools.forEachInArray(toBeDeleted, function (x)
        {
            mainView.lockFile(x.name);
            documentFolderId.deleteFile(x);
            commentsView.deleteComment(x.name);
        })
    }

    function deleteFile(file) {
        if (mainView.haveTheRighToModify(file.name)) {
            mainView.lockFile(file.name);
            documentFolderId.deleteFile(file);
        }
    }

    function refreshFiles()
    {
        documentFolderId.loadFiles();
        documentFolderId.loadRemoteFiles(documentFolderQueryStatus);
    }

    SplashScreen
    {
        id : splashScreenId
        width : parent.width
        height: parent.height
    }
}
