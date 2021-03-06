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

Rectangle
{
    id : checkBoxId
    height : 40
    width : parent.width

    color : item != null && item !== undefined && item.busy ? "lightgrey" : /*(index % 2 ? "#FFF2B7" :*/ "white" //)

    property bool checked : false

    ToolButton
    {
        height: 40
        width: 40

        anchors.verticalCenter: parent.verticalCenter


        action : Action
        {
            id : checkedBoxImage

            iconSource : checkBoxId.checked ? "qrc:/ZcCloud/Resources/checkbox_checked.png" : "qrc:/ZcCloud/Resources/checkbox_unchecked.png"

            onTriggered :
            {
                checkBoxId.checked = !checkBoxId.checked
                model.cast.isSelected = checkBoxId.checked
            }
        }
    }

    function selectUnselect(val)
    {
        checkBoxId.checked = val;
    }

    Component.onCompleted :
    {
        fodlerGridViewId.onSelectedAllChanged.connect(selectUnselect);
        checkBoxId.checked = model.cast.isSelected;
    }

    Component.onDestruction:
    {
        fodlerGridViewId.onSelectedAllChanged.disconnect(selectUnselect);
    }
}
