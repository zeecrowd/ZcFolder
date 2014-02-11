import QtQuick 2.0

FileTextDelegate
{
    position : index
    text : item.status === "upload" ? item.timeStampLabel : item.remoteTimeStampLabel
    isBusy : item != null && item !== undefined ?  item.busy : false
}
