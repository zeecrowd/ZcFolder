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

    // All files are selected
    signal selectedAllChanged(bool val);

    Flickable
    {
        anchors.fill: parent

        contentHeight: filesIconListView.contentHeight

        SplitView
        {
            id : splitView
            anchors.fill : parent
            orientation: Qt.Horizontal

            property string activeSort : "Name"

            handleDelegate: Rectangle { width: 1; color: "white"}

            function setModel(model)
            {
                //filesCheckListView.model = model;
                filesNameListView.model = model;
                filesIconListView.model = model;
                filesLockedListView.model = model;
                filesNbrCommentListView.model = model
                filesCalculateSizeListView.model = model;
                filesCalculateDateListView.model = model;
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

                header :
                    FileHeaderDelegate
                    {
                    text :  ""
                    width : filesIconListView.width
                    sortAvailable: false
                }
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
                spacing             : 10
                contentY            : filesCalculateDateListView.contentY
                Layout.minimumWidth : 100
                Layout.fillWidth    : true
                model               : parent.model
                interactive         : false
                delegate            : FileNameDelegate {}

                header              : FileHeaderDelegate {
                    text :  "Name"
                    width : filesNameListView.width
                    order : sortFilterObjectListModel.order
                    sortJavaScriptObjet : javaScriptSorterName
                    sortListModel : sortFilterObjectListModel
                    sortAvailable : splitView.activeSort === "Name"

                    onClicked:
                    {
                        splitView.activeSort = "Name"
                        switchSort()
                    }

                }
            }

            ListView
            {
                id                  : filesNbrCommentListView
                spacing             : 10
                Layout.minimumWidth : 80
                interactive         : false
                contentY            : filesCalculateDateListView.contentY
                delegate            : NbrCommentDelegate{}

                header              : FileHeaderDelegate {
                    text : qsTr("Comments")
                    width : filesNbrCommentListView.width
                    sortAvailable: false
                }
            }

            ListView
            {
                id                  : filesLockedListView
                spacing             : 10
                Layout.minimumWidth : 125
                interactive         : false
                contentY            : filesCalculateDateListView.contentY
                delegate            : LockedDelegate{}

                header              : FileHeaderDelegate {
                    text : "Locked by"
                    width : filesLockedListView.width
                    sortAvailable: false
                }
            }

            ListView
            {
                Zc.JavaScriptSorter
                {
                    id : javaScriptSorterSize

                    function lessThan(left,right)
                    {
                        var leftsize = left.status === "upload" ? left.sizeKb : left.remoteSizeKb
                        var rightsize = right.status === "upload" ? right.sizeKb : right.remoteSizeKb
                        return leftsize < rightsize;
                    }
                }


                id                  : filesCalculateSizeListView
                spacing             : 10
                Layout.minimumWidth : 100
                contentY            : filesCalculateDateListView.contentY
                model               : parent.model
                interactive         : false
                delegate            : SizeDelegate {}
                header              : FileHeaderDelegate {
                    text :  "Size";
                    width : filesCalculateSizeListView.width
                    order : sortFilterObjectListModel.order
                    sortJavaScriptObjet : javaScriptSorterSize
                    sortListModel : sortFilterObjectListModel
                    sortAvailable : splitView.activeSort === "Size"


                    onClicked:
                    {
                        splitView.activeSort = "Size"
                        switchSort();
                    }
                }
            }

            ListView
            {
                Zc.JavaScriptSorter {
                    id : javaScriptSorterDate

                    function lessThan(left,right)
                    {
                        var leftdate = left.status === "upload" ? left.timeStamp : left.remoteTimeStamp
                        var rightdate = right.status === "upload" ? right.timeStamp : right.remoteTimeStamp

                        return leftdate < rightdate;
                    }
                }

                id                    : filesCalculateDateListView
                spacing               : 10
                Layout.minimumWidth   : 200
                model                 : parent.model
                interactive           : false
                delegate              : DateDelegate {}
                header                : FileHeaderDelegate {
                    text :  "Date" ;
                    width :filesCalculateDateListView.width
                    sortJavaScriptObjet : javaScriptSorterDate
                    sortListModel : sortFilterObjectListModel
                    order : sortFilterObjectListModel.order
                    sortAvailable : splitView.activeSort === "Date"

                    onClicked:
                    {
                        splitView.activeSort = "Date"
                        switchSort()
                    }
                }
            }

        }
    }
}
