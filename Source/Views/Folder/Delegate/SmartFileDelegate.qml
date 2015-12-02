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

import "../Tools.js" as Tools

import ZcClient 1.0 as Zc

Item {

    width  : parent.width
    height : columnId.height

    property bool isBusy : item != null && item !== undefined ?  item.busy : false

    property bool isLocked : false

    Component.onCompleted: {
        calculateIsLocked();
        // CP : for mock
        if (item.datasChanged !== undefined) {
            item.datasChanged.connect(calculateIsLocked)
        }
    }

    function calculateIsLocked() {
        isLocked = mainView.isLocked(datas)
    }

    Column {
        id : columnId

        width : parent.width

        spacing: 0

        Item {
            width : parent.width
            height: Zc.AppStyleSheet.height(0.05)
        }

        RowLayout {

            width : parent.width
            height: Zc.AppStyleSheet.height(0.40)

            spacing: 0

            Item {
                Layout.fillHeight: true
                Layout.preferredWidth:  Zc.AppStyleSheet.width(0.05)
            }

            Item
            {
                Layout.fillHeight: true
                Layout.preferredWidth:  Zc.AppStyleSheet.width(0.36)

                Rectangle
                {
                    color : "lightblue"
                    anchors.fill: iconId
                }

                Image
                {
                    id : iconId
                    width : Zc.AppStyleSheet.width(0.36)
                    height : Zc.AppStyleSheet.height(0.36)

                    anchors.top : parent.top
                    anchors.left : parent.left

                    Component.onCompleted:
                    {
                        source = "image://icons/" + "file:///" + name
                    }

                }
            }

            Item {
                Layout.fillHeight: true
                Layout.preferredWidth:  Zc.AppStyleSheet.width(0.05)
            }

            Column {
                Layout.fillHeight: true
                Layout.fillWidth: true

                spacing: 0

                Text {
                    width : parent.width
                    text : name
                    font.pixelSize: Zc.AppStyleSheet.height(0.12)
                    color : "black"
                    elide : Text.ElideMiddle
                }
                Text {
                    width : parent.width
                    text : remoteSizeKb + " kb"
                    font.pixelSize: Zc.AppStyleSheet.height(0.10)
                    color : "grey"
                    elide : Text.ElideMiddle
                }

                RowLayout {
                    width : parent.width
                    Text {
                        Layout.fillWidth: true
                        text : remoteTimeStampLabel.replace(" GMT","")
                        font.pixelSize        : Zc.AppStyleSheet.height(0.08)
                        color: "grey"
                    }
                    Image
                    {
                        id : lockId
                        Layout.preferredWidth: Zc.AppStyleSheet.width(0.14)
                        Layout.preferredHeight : Zc.AppStyleSheet.height(0.14)

                        visible : isLocked
                        source : "../../../Resources/lock.png"
                    }
                }
            }
        }

        Rectangle {
            width : parent.width
            height : 1
            color : "lightGrey"
        }
    }

    Rectangle {
        anchors.top : parent.top
        anchors.bottom : parent.bottom
        anchors.left    : parent.left
        opacity : 0.5
        visible : isBusy || item.queryProgress > 0
        color   : isBusy && item.queryProgress === 0 ? "lightgrey" : "lightgreen"
        width  : isBusy && item.queryProgress === 0 ? parent.width : parent.width * item.queryProgress / 100
    }
}
