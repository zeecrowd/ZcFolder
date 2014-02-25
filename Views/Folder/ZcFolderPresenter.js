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

function nextUpload()
{
    if (filesToUpload.length > 0)
    {
        uploadRunning++;
        var file = filesToUpload.pop();


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
    instance.fileDescriptorToUpload[file.name] = file

    /*
    ** to now the state of the progress
    */
    file.queryProgressChanged.connect(function(){ updateQueryProgress(file.queryProgress,file.name) });


    uploadingFiles.append( { "name"  : file.name, "progress" : 0, "status" : "Waiting" })

    if (uploadRunning < maxNbrUpload)
    {       
        nextUpload();
    }
}

function updateQueryProgress(progress, fileName)
{
    setPropertyinListModel(uploadingFiles,"progress",progress,function (x) { return x.name === fileName });
}

instance.uploadFinished = function(fileName)
{
    instance.fileDescriptorToUpload[fileName] = null
    removeInListModel(uploadingFiles,function (x) { return x.name === fileName} );

    uploadRunning = uploadRunning - 1;
    nextUpload();
}

instance.downloadFinished = function()
{
    downloadRunning--;
    nextDownload();
}
