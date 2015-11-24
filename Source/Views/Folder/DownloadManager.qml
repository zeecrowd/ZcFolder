import QtQuick 2.5
import "Tools.js" as Tools
import ZcClient 1.0 as Zc

Item {

    property int maxNbrDomwnload : 5;
    property int downloadRunning : 0;
    property var filesToDownload : ([])

    property var documentFolder : null

    function startDownload(file) {
        filesToDownload.push(file)
        if (downloadRunning < maxNbrDomwnload) {
            nextDownload();
        }
    }
    function nextDownload() {
        if (filesToDownload.length > 0) {
            downloadRunning++;
            var file = filesToDownload.pop();
            documentFolder.downloadFile(file.cast)
        }
    }

    function downloadFinished() {
        downloadRunning--;
        nextDownload();
    }
}

