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

    // All files are selected
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

            handleDelegate: Rectangle { width: 1; color: "white"}

            function setModel(model)
            {
                filesCheckListView.model = model;
                filesNameListView.model = model;
                filesIconListView.model = model;
                filesSynchronizeListView.model = model;
                filesLockedListView.model = model;
                //filesModifyListView.model = model;
                filesCalculateSizeListView.model = model;
                filesCalculateDateListView.model = model;
            }

            ListView
            {
                Component
                {
                    id : headerCheckComponent
                    Item
                    {
                        height  : 30;
                        width   : parent.width;

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
                                    fodlerGridViewId.selectedAllChanged(checked);
                                }
                            }
                        }
                    }
                }

                id                  : filesCheckListView
                spacing             : 10
                contentY            : filesCalculateDateListView.contentY
                Layout.minimumWidth : 25
                Layout.maximumWidth : 25

                model       : parent.model
                interactive : false

                delegate    : CheckedDelegate {}

                header : headerCheckComponent
            }


            ListView
            {
                id                  : filesIconListView
                spacing             : 10
                contentY            : filesCalculateDateListView.contentY
                Layout.minimumWidth : 40
                Layout.maximumWidth : 40

                model       : parent.model
                interactive : false

                delegate    : FileIconDelegate {}

                header : FileHeaderDelegate { text :  "" }
            }



            ListView
            {
                id : filesNameListView
                spacing             : 10
                contentY            : filesCalculateDateListView.contentY
                Layout.minimumWidth : 100
                Layout.fillWidth    : true
                model               : parent.model
                interactive         : false
                delegate            : FileNameDelegate {}

                header              : FileHeaderDelegate { text :  "Name" }
            }


            //            ListView
            //            {
            //                id                  : filesModifyListView
            //                spacing             : 10
            //                Layout.minimumWidth : 125
            //                interactive         : false
            //                contentY            : filesCalculateDateListView.contentY
            //                delegate            : ModifyItDelegate { }


            //                header              : FileHeaderDelegate { text :  "Modifying" }
            //            }


            ListView
            {
                id                  : filesSynchronizeListView
                spacing             : 10


                Layout.minimumWidth : 125
                interactive         : false
                contentY            : filesCalculateDateListView.contentY
                delegate            : SynchronizeDelegate { }


                header              : FileHeaderDelegate { text :  "" }
            }

            ListView
            {
                id                  : filesLockedListView
                spacing             : 10
                Layout.minimumWidth : 125
                interactive         : false
                contentY            : filesCalculateDateListView.contentY
                delegate            : LockedDelegate{}


                header              : FileHeaderDelegate { text : "Locked by"}
            }


            ListView
            {
                id                  : filesCalculateSizeListView
                spacing             : 10
                Layout.minimumWidth : 100
                contentY            : filesCalculateDateListView.contentY
                model               : parent.model
                interactive         : false
                delegate            : SizeDelegate {}
                header              : FileHeaderDelegate { text :  "Size" }
            }

            ListView
            {
                id                    : filesCalculateDateListView
                spacing               : 10
                Layout.minimumWidth   : 200
                model                 : parent.model
                interactive           : false
                delegate              : DateDelegate {}
                header                : FileHeaderDelegate { text :  "Date" }
            }

        }
    }
}
