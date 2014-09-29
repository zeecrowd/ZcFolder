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

Qt.include("Tools.js")

var instance = {}

instance.fileStatus = {}

instance.fileDescriptorToUpload = {};

var maxNbrDomwnload = 5;
var maxNbrUpload = 5;

var uploadRunning = 0;
var downloadRunning = 0;

var filesToDownload = []
var filesToUpload = []

function nextDownload()
{

    if (filesToDownload.length > 0)
    {
        downloadRunning++;
        var file = filesToDownload.pop();
        documentFolder.downloadFile(file.cast)
    }
}

function verifyRightOrValidationToUploading(fileName)
{
    // All is ok
    // File doesn't exist in documentFolder
    var found = findInListModel(documentFolder.files, function(x) {return x.name === fileName} )

    if (found === null)
        return true;

    var lock = lockedActivityItems.getItem(fileName,"");

    // No lock or it's my lock
    if ( lock === "" || lock === mainView.context.nickname)
    {
        return true;
    }
    else
    {
        // If i am a admin need a validation
//        if ( mainView.context.affiliation >= 3 )
//        {
//            // Check has already have a validation
//            var o = findInListModel(uploadingFiles, function(x) {return x.name === fileName} )

//            if ( o !== null && o.validated)
//                return true;

//            setPropertyinListModel(uploadingFiles,"status","NeedValidation",function (x) { return x.name === fileName });
//            setPropertyinListModel(uploadingFiles,"message","File is locked by " + lock,function (x) { return x.name === fileName });
//        }
//        // File it's locked ... , i haven't got the right to upload the file
//        else
//        {
            setPropertyinListModel(uploadingFiles,"status","Error",function (x) { return x.name === fileName });
            setPropertyinListModel(uploadingFiles,"message","File is locked by " + lock,function (x) { return x.name === fileName });
        //}
        return false;
    }
}


function nextUpload()
{
    if (filesToUpload.length > 0)
    {
        instance.incrementUploadRunning();

        var file = filesToUpload.pop();

        // Have you the rights to upload this file ???
        // or need Validation ??
        if (!verifyRightOrValidationToUploading(file.descriptor.name))
        {
            instance.decrementUploadRunning();
            return;
        }

        if (file.path !== "" && file.path !== null && file.path !== undefined)
        {
            documentFolder.importFileToLocalFolder(file.descriptor,file.path,".upload")
        }
        else
        {
            setPropertyinListModel(uploadingFiles,"status","Uploading",function (x) { return x.name === file.descriptor.name });
            documentFolder.uploadFile(file.descriptor,".upload/" + file.descriptor.name)
        }
    }
}

instance.incrementUploadRunning = function()
{
    uploadRunning = uploadRunning + 1
}

instance.decrementUploadRunning = function()
{
    uploadRunning = uploadRunning - 1
}

instance.startDownload = function(file)
{
    filesToDownload.push(file)

    if (downloadRunning < maxNbrDomwnload)
    {
        nextDownload();
    }
}


instance.startUpload = function(file,path)
{   
    var fd = {}
    fd.descriptor = file;
    fd.path = path

    filesToUpload.push(fd)

    /*
    ** uploadingFiles contain all progress ulpoading files
    */
    if ( instance.fileDescriptorToUpload[file.name] === null || instance.fileDescriptorToUpload[file.name] === undefined)
    {
        instance.fileDescriptorToUpload[file.name] = file

        /*
        ** to now the state of the progress
        */
        file.queryProgressChanged.connect(function(){ updateQueryProgress(file.queryProgress,file.name) });
    }

    var found = findInListModel(uploadingFiles, function(x) {return x.name === file.name} )

    if (found === null)
    {
        uploadingFiles.append( { "name"  : file.name,
                                 "action" : "Upload",
                                 "progress" : 0,
                                 "status" : "Waiting",
                                 "message" : "",
                                 "localPath" : path,
                                  "validated" : false
                          })
    }
    else
    {
        setPropertyinListModel(uploadingFiles,"localPath",path,function (x) { return x.name === file.name });

        // TO DO : check override filename
    }

    if (uploadRunning < maxNbrUpload)
    {
        nextUpload();
    }
}

function updateQueryProgress(progress, fileName)
{
    setPropertyinListModel(uploadingFiles,"progress",progress,function (x) { return x.name === fileName });
}

/*
** Upload is finished
** clean all object and try to do an next upload
*/
instance.uploadFinished = function(fileName,notify)
{
    var fileDescriptor = instance.fileDescriptorToUpload[fileName];

    if (fileDescriptor !== null && fileDescriptor !== undefined)
    {
        documentFolder.removeLocalFile(".upload/" + fileDescriptor.name)
        /*
        ** For example if it's a cancel : no notification for all users
        */
        if (notify)
            notifySender.sendMessage("","{ \"sender\" : \"" + mainView.context.nickname + "\", \"action\" : \"added\" , \"fileName\" : \"" + fileName + "\" , \"size\" : " +  fileDescriptor.size + " , \"lastModified\" : \"" + fileDescriptor.timeStamp + "\" }");
    }
    instance.fileDescriptorToUpload[fileName] = null
    removeInListModel(uploadingFiles,function (x) { return x.name === fileName} );
    instance.decrementUploadRunning();
    nextUpload();
}

instance.downloadFinished = function()
{
    downloadRunning--;
    nextDownload();
}
