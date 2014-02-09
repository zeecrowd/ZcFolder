import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.0

import ZcClient 1.0


import "Tools.js" as Tools


Item
{

    anchors.fill: parent


    function setModel(model)
    {
        repeater.model = model
    }

    signal clean();

    Slider
    {
        id              : slider
        anchors.top     : parent.top
        anchors.left    : parent.left
        anchors.right   : parent.right

        height: 30

        value : 1

        maximumValue: 2
        minimumValue: 0.5
        stepSize: 0.1

        orientation : Qt.Horizontal
    }


    ScrollView
    {
        id : fodlerGridIconeViewId

        anchors.top: slider.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom




        Flow
        {
            id : listView
            anchors.top  : parent.top
            anchors.left : parent.left

            width : slider.width

            flow : Flow.LeftToRight

            spacing: 10

            Repeater {
                id : repeater


                Item
                {

                    width: 200 * slider.value
                    height: 200 * slider.value


                    Rectangle
                    {
                        anchors.fill: parent
                        color : "lightgrey"
                        opacity: 0.5
                    }

                    Image
                    {
                        id : image
                        anchors.top: parent.top
                        anchors.left: parent.left

                        asynchronous: true

                        width : parent.width
                        height : 200 * slider.value - 20

                        fillMode: Image.PreserveAspectFit

                        Component.onCompleted:
                        {
                            refreshImage();
                        }


                        MouseArea
                        {
                            anchors.fill: parent

                            onClicked:
                            {
                                if (!item.cast.isBusy)
                                {
                                    mainView.openFile(item)
                                }
                            }
                        }


                        function refreshImage()
                        {
                            image.source = "";

                            if (item.status === "" ||item.status === null || item.status === "upload")
                            {
                                source = "image://icons/" + "file:///" + documentFolder.localPath + item.cast.name
                            }
                            else
                            {
                                source = "image://icons/" + "file:///" + item.cast.name
                            }
                        }

                        onStatusChanged:
                        {
                            if (status == Image.Error)
                            {
                                extension.text = item.cast.suffix();
                            }
//                            else
//                            {
//                                if (sourceSize.width < parent.width && sourceSize.height < parent.height)
//                                {
//                                    image.width = sourceSize.width;
//                                    image.height = sourceSize.height;

//                                    image.anchors.centerIn = parent;
//                                }

//                            }

                        }

                    }

                    Image
                    {
                        height      : 25
                        width       : 25

                        anchors.bottom: image.bottom
                        anchors.right: parent.right
                        anchors.leftMargin: 3
                        anchors.rightMargin: 3

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

                    ProgressBar
                    {
                        anchors.verticalCenter: image.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        visible : image.status == Image.Loading
                        opacity: 0.5

                        height : 20
                        width : image.width - 10
                        minimumValue: 0
                        maximumValue: 1
                        value       : image.progress
                    }

                    ProgressBar
                    {
                        anchors.verticalCenter: image.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 5

                        visible : item.queryProgress > 0
                        opacity: 0.5

                        height : 20
                        width  : image.width - 10 //) * item.queryProgress / 100

                        minimumValue: 0
                        maximumValue: 100
                        value       : item.queryProgress


                        onVisibleChanged:
                        {
                            if (visible === false)
                            {
                                image.refreshImage();
                            }
                        }
                     }

                    Rectangle
                    {
                        width : parent.width
                        height: 20

                        anchors.left : parent.left
                        anchors.top : image.bottom

                        color : "lightgrey"
                        opacity: 0.5

                        Label
                        {
                            anchors.fill: parent

                            font.pixelSize: 16
                            text : model.name
                            elide : Text.ElideRight

                            horizontalAlignment: Text.AlignHCenter

                        }
                    }


                    Label
                    {
                        id : extension
                        width : parent.width
                        anchors.centerIn: parent
                        font.pixelSize: 25
                        text : model.name
                        elide : Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter

                        visible: image.status === Image.Error
                    }


                    //        CheckBox
                    //        {
                    //            id : checkBox
                    //            anchors.left: parent.left
                    //            anchors.top: parent.top
                    //            anchors.leftMargin: 3
                    //            anchors.rightMargin: 3

                    //            enabled : !item.busy

                    //            onCheckedChanged:
                    //            {
                    //                model.cast.isSelected = checked
                    //            }

                    //            Component.onCompleted :
                    //            {
                    //                checked = model.cast.isSelected;
                    //            }
                    //        }
                }

            }

        }
    }

}
