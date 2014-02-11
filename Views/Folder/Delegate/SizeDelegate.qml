import QtQuick 2.0

FileTextDelegate
{
    position : index
    text : item.status === "upload" ? item.sizeKb + " kb" : item.remoteSizeKb + " kb"
    isBusy : item != null && item !== undefined ?  item.busy : false
}
