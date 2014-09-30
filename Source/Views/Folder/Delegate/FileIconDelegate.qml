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

import QtQuick 2.2

Image
{
    width: 40
    height: 40

    Component.onCompleted:
    {
        if (item.status === "" ||item.status === null || item.status === "upload")
        {
            source = "image://icons/" + "file:///" + documentFolder.localPath + item.cast.name
        }
        else
        {
            source = "image://icons/" + "file:///" + item.cast.name
        }

    }

    MouseArea
    {
        anchors.fill: parent

        onClicked: mainView.openFile(item)
    }
}