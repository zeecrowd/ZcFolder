import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import "./Delegate"
import "Tools.js" as Tools

ScrollView
{
    anchors.fill: parent

    id : fodlerGridViewId

    function setModel(model)
    {
        splitView.setModel(model)
    }

    signal clean();
    signal selectedAllChanged(bool val);

    Flickable
    {
        anchors.fill: parent

        contentHeight: filesCheckListView.contentHeight

        SplitView
        {
            id : splitView
            anchors.fill : parent
            orientation: Qt.Horizontal

            function setModel(model)
            {
                filesCheckListView.model = model;
                filesNameListView.model = model;
                //filesStatusListView.model = model;
                //filesProgressListView.model = model;
                filesSynchronizeListView.model = model;
                filesLockedListView.model = model;
                filesCalculateSizeListView.model = model;
                filesCalculateDateListView.model = model;
                //                filesSizeListView.model = model;
                //                filesDateListView.model = model;
                //                filesRemoteSizeListView.model = model;
                //                filesRemoteDateListView.model = model;

            }

            ListView
            {
                id                  : filesCheckListView
                spacing             : 5
                contentY            : filesCalculateDateListView.contentY
                Layout.minimumWidth : 25
                Layout.maximumWidth : 25

                model       : parent.model
                interactive : false

                delegate    : Rectangle
                {
                height : 25
                width : parent.width
                color : item != null && item !== undefined && item.busy ? "lightgrey" : (index % 2 ? "#FFF2B7" : "white")
                CheckBox
                {
                    id : checkBox
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left    : parent.left
                    anchors.leftMargin: 7
                    enabled : !item.busy


                    // checked: model.cast.isSelected

                    onCheckedChanged:
                    {
                        model.cast.isSelected = checked
                    }

                }



                Component.onCompleted :
                {
                    fodlerGridViewId.onSelectedAllChanged.connect(function (x)
                    {
                        checkBox.checked = x});

                    checkBox.checked = model.cast.isSelected;

                }
            }

            header : Item
            {
            height  : 30
            width   : parent.width

            Rectangle
            {
                width       : parent.width
                height      : 25
                anchors.top : parent.top
                color       : "lightBlue"

                radius      : 3

                CheckBox
                {
                    id : allSelected
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left    : parent.left
                    anchors.leftMargin: 7
                    enabled : !item.busy
                    onCheckedChanged:
                    {
                        //                                Tools.forEachInObjectList( filesCheckListView.model, function(x)
                        //                                {
                        //                                    if (!x.cast.busy)
                        //                                    {
                        //                                        x.cast.isSelected = checked
                        //                                    }
                        //                                });
                        fodlerGridViewId.selectedAllChanged(checked);
                    }
                }
            }
        }
    }

    ListView
    {
        id : filesNameListView
        spacing             : 5
        contentY            : filesCalculateDateListView.contentY
        Layout.minimumWidth : 100
        Layout.fillWidth    : true
        model               : parent.model
        interactive         : false
        delegate            :
            FileTextDelegate
        {
        text : name
        isBusy : item != null && item !== undefined ?  item.busy : false
        position : index

        onClicked : mainView.openFile(item)
        notifyPressed: true

        Rectangle
        {
            anchors.top : parent.top
            anchors.bottom : parent.bottom
            anchors.left    : parent.left
            opacity : 0.5
            visible : item.queryProgress > 0
            color   : "green"

            width  : parent.width * item.queryProgress / 100
        }
    }

    header              : FileHeaderDelegate { text :  "Name" }
}

//            ListView
//            {
//                id                  : filesStatusListView
//                spacing             : 5
//                Layout.minimumWidth : 100
//                interactive         : false
//                contentY            : filesCalculateDateListView.contentY
//                delegate            : FileTextDelegate
//                {
//                    text : item.status
//                    isBusy : item != null && item !== undefined ?  item.busy : false
//                    position : index
//                }
//                header              : FileHeaderDelegate { text :  "Status" }
//            }

//		    ListView
//		    {
//		        id                  : filesProgressListView
//		        spacing             : 5
//		        Layout.minimumWidth : 100
//		        interactive         : false
//		        contentY            : filesDateListView.contentY
//                delegate            : FileTextDelegate
//                {
//                text : queryProgress
//                isBusy : busy
//            }
//		        header              : FileHeaderDelegate { text :  "Progress" }
//		    }

ListView
{
    id                  : filesSynchronizeListView
    spacing             : 5
    Layout.minimumWidth : 25
    interactive         : false
    contentY            : filesCalculateDateListView.contentY
    delegate            :
        Rectangle
    {
    height      : 25
    width       : 25
    color       : item != null && item !== undefined && item.busy ? "lightgrey" : (index % 2 ? "#FFF2B7" : "white")
    Image
    {
        anchors.fill: parent
        visible    : item.status !== "" && !item.busy
        source : item.status === "upload" ? "qrc:/ZcCloud/Resources/export.png" : "qrc:/ZcCloud/Resources/import.png"

        MouseArea
        {
            anchors.fill: parent
            enabled     : parent.visible

            onClicked:
            {
                mainView.synchronize(item)
            }
        }
    }
}
header              : FileHeaderDelegate { }
}

ListView
{
    id                  : filesLockedListView
    spacing             : 5
    Layout.minimumWidth : 25
    interactive         : false
    contentY            : filesCalculateDateListView.contentY
    delegate            : LockedDelegate{}


    header              : FileHeaderDelegate { }
}


ListView
{
    id                  : filesCalculateSizeListView
    spacing             : 5
    Layout.minimumWidth : 100
    contentY            : filesCalculateDateListView.contentY
    model               : parent.model
    interactive         : false
    delegate            : FileTextDelegate {
        position : index
        text : item.status === "upload" ? item.sizeKb + " kb" : item.remoteSizeKb + " kb"
        isBusy : item != null && item !== undefined ?  item.busy : false
    }
    header              : FileHeaderDelegate { text :  "Size" }
}

ListView
{
    id                    : filesCalculateDateListView
    spacing               : 5
    Layout.minimumWidth   : 200
    model                 : parent.model
    interactive           : false
    delegate              : FileTextDelegate {
        position : index
        text : item.status === "upload" ? item.timeStampLabel : item.remoteTimeStampLabel
        isBusy : item != null && item !== undefined ?  item.busy : false
    }
    header                : FileHeaderDelegate { text :  "Date" }
}




//            ListView
//            {
//                id                  : filesSizeListView
//                spacing             : 5
//                Layout.minimumWidth : 100
//                contentY            : filesDateListView.contentY
//                model               : parent.model
//                interactive         : false
//                delegate            : FileTextDelegate {
//                    position : index
//                    text : item.sizeKb + " kb"
//                    isBusy : item != null && item !== undefined ?  item.busy : false
//                }
//                header              : FileHeaderDelegate { text :  "Size" }
//            }

//            ListView
//            {
//                id                    : filesDateListView
//                spacing               : 5
//                Layout.minimumWidth   : 200
//                model                 : parent.model
//                interactive           : false
//                delegate              : FileTextDelegate {
//                    position : index
//                    text : item.timeStampLabel
//                    isBusy : item != null && item !== undefined ?  item.busy : false
//                }
//                header                : FileHeaderDelegate { text :  "Date" }
//            }

//            ListView
//            {
//                id                  : filesRemoteSizeListView
//                spacing             : 5
//                Layout.minimumWidth : 100
//                contentY            : filesDateListView.contentY
//                model               : parent.model
//                interactive         : false
//                delegate            : FileTextDelegate {
//                    text : item.remoteSizeKb + " kb"
//                    isBusy : item != null && item !== undefined ?  item.busy : false
//                    position : index
//                }
//                header              : FileHeaderDelegate { text :  "Remote Size" }
//            }

//            ListView
//            {
//                id                    : filesRemoteDateListView
//                spacing               : 5
//                Layout.minimumWidth   : 200
//                contentY              : filesDateListView.contentY
//                model                 : parent.model
//                interactive           : false
//                delegate              : FileTextDelegate {
//                    text : item.remoteTimeStampLabel
//                    isBusy : item != null && item !== undefined ?  item.busy : false
//                    position : index
//                }
//                header                : FileHeaderDelegate { text :  "Remote Date" }
//            }
}
}
}
