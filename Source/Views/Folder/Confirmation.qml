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

Rectangle
{
    id : confirmationId
    width : parent.width
    height: parent.height

    visible : false

    color : "lightgrey"

    property QtObject file : null
    property string fileName : ""
    property bool upload : true

    signal clicked()

    Row
    {
        height : 100
        width : parent.width * 2/3 + 50

        anchors.centerIn: parent

        spacing: 10

        Column
        {
            height : 100
            width : parent.width * 2/3

            Label
            {
                text : confirmationId.upload ? "Do you really want to override the distant file?": "Do you really want to override your local file  ?"

                font.pixelSize: 18
                color : "black"
            }

            Item
            {
                height : 20
                width : 20
            }

            Label
            {
                font.pixelSize: 18
                text : confirmationId.fileName
                color : "black"
            }
        }

        Column
        {
            height : 100
            width : 50

            spacing: 5

            Button
            {

                height : 50
                width : 50

                style: ButtonStyle {
                    background: Item {
                        implicitWidth: 50
                        implicitHeight: 50


                        Image
                        {
                            source : "qrc:/ZcCloud/Resources/ok.png"
                            anchors.fill: parent
                        }

                        Rectangle
                        {
                            anchors.fill: parent
                            color : control.pressed ? "#AAAAAA" : "#00000000"
                            opacity : 0.8
                        }
                    }

                }

                onClicked:
                {
                    confirmationId.clicked();
                }
            }

            Button
            {
                height : 50
                width : 50
                style: ButtonStyle {
                    background: Item {
                        implicitWidth: 50
                        implicitHeight: 50


                        Image
                        {
                            source : "qrc:/ZcCloud/Resources/cancel.png"
                            anchors.fill: parent
                        }

                        Rectangle
                        {
                            anchors.fill: parent
                            color : control.pressed ? "#AAAAAA" : "#00000000"
                            opacity : 0.8
                        }
                    }
                }

                onClicked:
                {
                    confirmationId.visible = false
                }
            }
    }
}
}
