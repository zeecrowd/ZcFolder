import QtQuick 2.5
import "Tools.js" as Tools
import ZcClient 1.0 as Zc

Item {

    property var documentFolder : null
    property var lockedActivityItems : null
    property var theNotifySender : null;
    property ListModel uploadingListFiles : null

    property int maxNbrUpload : 5;
    property int uploadRunning : 0;

    property var fileDescriptorToUpload : ({})
    property var filesToUpload : [];


    function uploadStatusChanged(x,fileName) {
        if (x.statusCode === "500") {
            Tools.setPropertyinListModel(uploadingListFiles,"status","Error",function (y) { return y.name === fileName });
        }
    }

    function decrementUploadRunning() {
        uploadRunning = uploadRunning - 1
    }

    function incrementUploadRunning() {
        uploadRunning = uploadRunning + 1
    }

    // Si le fichier n'existe pas : Ok
    // Si le fichier existe et qu'il n'est pas locké : Ok
    // Si le fichier existe et qu'il est locké par moi  : Ok
    function verifyRightOrValidationToUploading(fileName) {
        // All is ok
        // File doesn't exist in documentFolder
        var found = Tools.findInListModel(documentFolder.files, function(x) {return x.name === fileName} )

        if (found === null)
            return true;

        var lock = lockedActivityItems.getItem(fileName,"");

        // No lock or it's my lock
        if ( lock === "" || lock === mainView.context.nickname) {
            return true;
        } else {
            Tools.setPropertyinListModel(uploadingListFiles,"status","Error",function (x) { return x.name === fileName });
            Tools.setPropertyinListModel(uploadingListFiles,"message","File is locked by " + lock,function (x) { return x.name === fileName });
            return false;
        }
    }

    function nextUpload() {
        if (filesToUpload.length > 0) {
            incrementUploadRunning();
            var file = filesToUpload.pop();
            // Have you the rights to upload this file ???
            // or need Validation ??
            if (!verifyRightOrValidationToUploading(file.descriptor.name)) {
                decrementUploadRunning();
                return;
            }

            if (file.path !== "" && file.path !== null && file.path !== undefined) {
                documentFolder.importFileToLocalFolder(file.descriptor,file.path,".upload")
            } else {
                Tools.setPropertyinListModel(uploadingListFiles,"status","Uploading",function (x) { return x.name === file.descriptor.name });
                documentFolder.uploadFile(file.descriptor,".upload/" + file.descriptor.name)
                file.descriptor.query.statusChanged.connect(function (x) { uploadStatusChanged(x,file.descriptor.name) })
            }
        }
    }

    function startUpload(file,path) {
        var fd = {}
        fd.descriptor = file;
        fd.path = path

        filesToUpload.push(fd)

        /*
        ** uploadingFiles contain all progress ulpoading files
        */
        if ( fileDescriptorToUpload[file.name] === null || fileDescriptorToUpload[file.name] === undefined) {
            fileDescriptorToUpload[file.name] = file
            /*
            ** to now the state of the progress
            */
            file.queryProgressChanged.connect(function(){ updateQueryProgress(file.queryProgress,file.name) });
        }

        var found = Tools.findInListModel(uploadingFiles, function(x) {return x.name === file.name} )

        if (found === null) {
            uploadingFiles.append( { "name"  : file.name,
                                      "action" : "Upload",
                                      "progress" : 0,
                                      "status" : "Waiting",
                                      "message" : "",
                                      "localPath" : path,
                                      "validated" : false
                                  })
        } else {
            Tools.setPropertyinListModel(uploadingFiles,"localPath",path,function (x) { return x.name === file.name });
        }

        if (uploadRunning < maxNbrUpload) {
            nextUpload();
        }
    }

    /*
    ** Upload is finished
    ** clean all object and try to do an next upload
    */
    function uploadFinished(fileName,notify) {
        var fileDescriptor = fileDescriptorToUpload[fileName];

        if (fileDescriptor !== null && fileDescriptor !== undefined) {
            documentFolder.removeLocalFile(".upload/" + fileDescriptor.name)
            /*
            ** For example if it's a cancel : no notification for all users
            */
            if (notify)
                theNotifySender.sendMessage("","{ \"sender\" : \"" + mainView.context.nickname + "\", \"action\" : \"added\" , \"fileName\" : \"" + fileName + "\" , \"size\" : " +  fileDescriptor.size + " , \"lastModified\" : \"" + fileDescriptor.timeStamp + "\" }");
        }
        fileDescriptorToUpload[fileName] = null
        Tools.removeInListModel(uploadingFiles,function (x) { return x.name === fileName} );
        decrementUploadRunning();
        nextUpload();
    }


    function updateQueryProgress(progress, fileName) {
        Tools.setPropertyinListModel(uploadingFiles,"progress",progress,function (x) { return x.name === fileName });
    }

}
