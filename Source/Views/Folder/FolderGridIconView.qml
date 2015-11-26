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

import QtQuick 2.5
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2

import "./Delegate"

//import ZcClient 1.0 as Zc


import "Tools.js" as Tools


Item
{

    anchors.fill: parent


    function setModel(model)
    {
        repeater.model = model
    }


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

        anchors
        {
            top     : slider.bottom
            left    : parent.left
            right   : parent.right
            bottom  : parent.bottom
        }

        Flow
        {
            id : listView

            anchors
            {
                top  : parent.top
                left : parent.left
            }

            width : slider.width
            flow  : Flow.LeftToRight

            spacing: 10

            Repeater
            {
                id : repeater

                Item
                {

                    width  : 200 * slider.value
                    height : 200 * slider.value

                    Rectangle
                    {
                        anchors.fill: parent
                        color : "lightgrey"
                        opacity: 0.5
                    }

                    Image
                    {
                        id : image

                        anchors
                        {
                            top: parent.top
                            left: parent.left
                        }

                        asynchronous: true

                        width  : parent.width
                        height: 200 * slider.value - 2

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
                                    mainView.showFileContextualMenu(item)
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


                    LockedDelegate
                    {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.rightMargin: 3
                        anchors.topMargin: 3

                    }

                }

            }

        }
    }

}
