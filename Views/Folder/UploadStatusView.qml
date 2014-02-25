import QtQuick 2.0
import QtQuick.Controls 1.0

import "./Delegate"

Item
{
    width: 100
    height: 62


    function setModel(model)
    {
        uploadingFilesView.model = model
    }

    ListView
    {
        id : uploadingFilesView

        spacing: 5

        anchors
        {
            top : parent.top
            topMargin : 5
            right : parent.right
            left : parent.left
            bottom : parent.bottom
        }

        delegate: UploadViewDelegate{}
    }
}
