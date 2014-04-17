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

import QtQuick 2.0


Item
{
    id : delegateHeader
    height  : 30
    width   : 100

    signal clicked();

    property alias text : theText.text
    property alias sortAvailable : imageSort.visible

    property QtObject sortJavaScriptObjet : null
    property QtObject sortListModel : null

    property int order : 0

    function switchSort()
    {
        if (!sortAvailable)
        {
            sortAvailable = true;
            sortListModel.order = 0
        }
        else
        {
            if (sortListModel.order === 0)
                sortListModel.order = 1;
            else
                sortListModel.order = 0;

        }

        order = sortListModel.order
        imageSort.source = sortListModel.order === 0 ? "qrc:/ZcCloud/Resources/down.png" : "qrc:/ZcCloud/Resources/up.png"

        sortJavaScriptObjet.qmlObjectSorter = sortJavaScriptObjet;
        sortListModel.setSorter(sortJavaScriptObjet);
        sortListModel.refresh();
    }

    Rectangle
    {
        width       : parent.width
        height      : 25
        anchors.top : parent.top
        color       : "lightBlue"

        radius      : 3

        Text
        {
            id                          : theText
            anchors.centerIn            : parent
        }

        Image
        {
            id : imageSort
            anchors.top     : parent.top
            anchors.topMargin     : 5
            anchors.right   : parent.right
            anchors.rightMargin     : 5
            anchors.bottom  : parent.bottom
            anchors.bottomMargin     : 5

            width : height

            source : delegateHeader.order === 0 ? "qrc:/ZcCloud/Resources/down.png" : "qrc:/ZcCloud/Resources/up.png"
        }

        MouseArea
        {
            anchors.fill: parent
            onClicked:
            {
                delegateHeader.clicked();
            }
        }
    }
}
