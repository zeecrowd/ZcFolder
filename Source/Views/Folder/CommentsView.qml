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

import "../../Components" as FolderComponents
import ZcClient 1.0 as Zc

Rectangle
{
    property var fileDescriptor : null
    property string __commentDirectory : ".comments/"

    anchors.fill: parent
    color : "white"

    ListModel
    {
        id : currentComments
    }

    function setAppContext(appContext) {
        sharedResource.setAppContext(appContext);
        senderCommentNotify.setAppContext(appContext);
        listenerCommentNotify.setAppContext(appContext);
    }

    Zc.MessageSender
    {
        id      : senderCommentNotify
        subject : "Comment"
    }

    Zc.MessageListener
    {
        id      : listenerCommentNotify
        subject : "Comment"

        onMessageReceived :
        {
            console.log(">> onMessageReceived " + message.body)

            if (fileDescriptor === null)
                return;

            if (message.body !== fileDescriptor.name)
                return;

            loadComments()

            /*var o = Tools.parseDatas(message.body);

            if ( o.url !==null && o.url !== undefined )
            {
                appNotification.blink();
                if (!mainView.isCurrentView)
                {
                    appNotification.incrementNotification();
                }

                // pour l'instant on refait un Get ...
                // a optimiser ..
                if (o.url === loader.item.getPreviewSource())
                {
                    loadComments(o.url)
                }
            }*/
        }
    }


    Zc.CrowdSharedResource
    {
        id   : sharedResource
        name : "Comments"


        Zc.StorageQueryStatus
        {
            id : getSharedResourceQueryStatus

            onErrorOccured : {
                console.log(">> getSharedResourceQueryStatus.Error")
                busyIndicator.running = false
            }

            onCompleted : {
                busyIndicator.running = false

                if (fileDescriptor == null)
                    return;

                console.log(">> getSharedResourceQueryStatus.Completed " + sender.content)
                if (sender.content === null || sender.content === undefined || sender.content !== fileDescriptor.name) {
                    return;
                }

                var result = Tools.parseDatas(sender.text);

                console.log(">> result " + result)

                currentComments.clear();

                if (result.datas !== null && result.datas !== undefined)
                {
                    Tools.forEachInArray(result.datas , function (x) {

                        if (x.comment === null || x.comment === undefined)
                        {
                            x.comment = ""
                        }

                        if (x.date === null || x.date === undefined || x.date === "")
                        {
                            x.date = 0;
                        }

                        console.log(">> append " + x.comment)
                        currentComments.append({ "who" : x.who, "comment" : x.comment, "date" : x.date, "identifier" : x.id })});

                    // voiture balai qui met le compteur à jour
                    //var name = sharedResource.getNameFromUrl(sender.content)
                    //nbrComments.setItem(name,result.datas.length);
                }

            }
        }

        Zc.StorageQueryStatus
        {
            id : putSharedResourceQueryStatus

            property string newComment : ""
            property string fileName : ""

            onErrorOccured :
            {
                busyIndicator.running = false
            }

            onCompleted :
            {
                busyIndicator.running = false

                //var toNotify = sender.content;

                console.log(">> call senderCommentNotify.sendMessage " + fileName)

                senderCommentNotify.sendMessage("",fileName)

                //appNotification.logEvent(Zc.AppNotification.Add,"Photo Comment",newComment,url)

                // Apres avoir pushé le nouveau commentaire on
                // met le compteur d emessages à jour
                //if (toNotify.url !== null && toNotify.url !== undefined || toNotify.url !== "")
                //{
                //    var name = sharedResource.getNameFromUrl(url)
                //    nbrItem.setItem(name,result.datas.length);
                //}
            }

        }

    }

    function deleteComments(fileName) {
        sharedResource.deleteFile(__commentDirectory + fileName + "_txt",null)
    }

    function putComments(filename,comment)
    {
        console.log(">> putComments " + filename + " -> " + comment)

        if (comment === "" || comment === null || comment === undefined)
            return;

        var result = {};
        result.datas = [];


        Tools.forEachInListModel(currentComments, function (x)
        {  var elm = {}
            elm.comment = x.comment
            elm.who = x.who
            elm.date = x.date
            elm.id = x.id
            result.datas.push(elm);
        })


        var newElm = {}
        newElm.who = mainView.context.nickname
        newElm.comment = comment
        var d = new Date();
        newElm.id = mainView.context.nickname + "_" + d.getTime();

        newElm.date = new Date().getTime()
        result.datas.unshift(newElm);
        var toPut = JSON.stringify(result);

        //   newElm.fileName = filename
        //   var toNotify = JSON.stringify(newElm)

        //putSharedResourceQueryStatus.content = toNotify

        putSharedResourceQueryStatus.fileName = filename
        putSharedResourceQueryStatus.newComment = comment;

        sharedResource.putText(__commentDirectory + filename + "_txt",toPut,putSharedResourceQueryStatus);
    }

    function loadComments() {

        console.log(">> loadComments")
        if (fileDescriptor === null)
            return;

        // on ne sait jamais on cancel al requete précedente
        getSharedResourceQueryStatus.cancel()

        getSharedResourceQueryStatus.content = fileDescriptor.name;

        console.log(">> getText " + __commentDirectory + fileDescriptor.name  + "_txt")

        sharedResource.getText(__commentDirectory + fileDescriptor.name  + "_txt",getSharedResourceQueryStatus);
    }

    onFileDescriptorChanged: {

        currentComments.clear()

        if (fileDescriptor == null) {
            busyIndicator.running = false;
            return;
        }

        busyIndicator.running = true;
        loadComments();
    }

    ListView {
        anchors {
            top : parent.top
            right : parent.right
            left : parent.left
            bottom : toolBar.top
            margins : 3
        }

        spacing : Zc.AppStyleSheet.height(0.05)

        model : currentComments
        delegate : CommentDelegate {
            contactImageSource : activity.getParticipantImageUrl(model.who)
        }
    }


    FolderComponents.ToolBar {
        id: toolBar
        Layout.fillWidth: true

        anchors.bottom: parent.bottom

        RowLayout {
            anchors.fill: parent
            anchors.margins: Zc.AppStyleSheet.width(0.02)

            FolderComponents.ToolButton {
                text: qsTr("Back")
                Layout.alignment: Qt.AlignCenter
                // Layout.fillWidth: true
                Layout.fillHeight: true
                // Layout.preferredWidth:
                onClicked: {
                    commentsView.visible = false;
                }
            }

            FolderComponents.ToolButton {
                text: qsTr("Add New")
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                onClicked: {
                    oneCommentView.message = "";
                    oneCommentView.show();
                }
            }
        }
    }

    FolderComponents.BusyIndicator {
        id : busyIndicator
        anchors.fill: parent
    }

    OnCommentView {
        id : oneCommentView
        onAddClicked: {
            putComments(fileDescriptor.name,message);
        }
    }

}
