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
import "Tools.js" as Tools

import ZcClient 1.0 as Zc


ScrollView
{
    anchors.fill: parent

    id : fodlerGridViewId

    function setModel(model)
    {
        splitView.setModel(model)
    }

    Flickable
    {
        anchors.fill: parent

        contentHeight: filesNameListView.contentHeight

        SplitView
        {
            id : splitView
            anchors.fill : parent
            orientation: Qt.Horizontal

            property string activeSort : "Name"

            handleDelegate: Rectangle { width: 1; color: "white"}

            function setModel(model)
            {
                filesNameListView.model = model;
            }

            ListView
            {

                Zc.JavaScriptSorter
                {
                    id : javaScriptSorterName

                    function lessThan(left,right)
                    {
                        return left.name < right.name;
                    }
                }

                id : filesNameListView
                spacing             : 0
                Layout.minimumWidth : 100
                Layout.fillWidth    : true
                model               : parent.model
                interactive         : false
                delegate            : SmartFileDelegate {
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (busy)
                                return;
                            mainView.showFileContextualMenu(model)
                        }
                    }
                }
            }
        }
    }
}
