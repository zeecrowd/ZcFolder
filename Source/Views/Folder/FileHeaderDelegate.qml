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

import ZcClient 1.0 as Zc

Item
{
    id : delegateHeader
    height  : Zc.AppStyleSheet.height(0.26)
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

        validate.iconSource = sortListModel.order === 0 ? "../../Resources/down.png" : "../../Resources/up.png"

        sortJavaScriptObjet.qmlObjectSorter = sortJavaScriptObjet;
        sortListModel.setSorter(sortJavaScriptObjet);
        sortListModel.refresh();

        // refresh the repeater view
        sortListModel.setModel(null);
        sortListModel.setModel(documentFolderId.files)
    }

    Rectangle
    {
        width       : parent.width
        height      : Zc.AppStyleSheet.height(0.26)
        anchors.top : parent.top
        color       : "lightBlue"

        radius      : 3

        Text
        {
            id                          : theText
            anchors.centerIn            : parent
        }

        ToolButton
        {
            id : imageSort
            anchors.top     : parent.top
            anchors.right   : parent.right
            anchors.bottom  : parent.bottom
            anchors.bottomMargin     : Zc.AppStyleSheet.height(0.05)

            width : height

            action : Action
            {
                id : validate
                iconSource : delegateHeader.order === 0 ? "../../Resources/down.png" : "../../Resources/up.png"
                tooltip     : "Sort"

            onTriggered :
            {
                delegateHeader.clicked();
            }

        }

        }
}
}
