import QtQuick 2.5
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.2

import ZcClient 1.0 as Zc

FocusScope {
    id: alertInstance
    anchors.fill: parent
	visible: false
    z: parent.z+1
	
    property var context
    property string title : qsTr("Your new comment:")
    property string message
    property string button1: qsTr("Cancel")
    property string button2: qsTr("Add")
    property color button1Color: "black"
    property color button2Color: "black"
    property bool autoCloseOnClick: false

//	signal button1Clicked
    signal addClicked

    function show() {
        alertInstance.visible = true;
        textArea.forceActiveFocus();
    }

    /*function showMessage(message) {
        alertInstance.message = message;
        alertInstance.visible = true;
    }*/

    /*function showTitleMessage(title, message) {
        alertInstance.title = title;
        alertInstance.message = message;
        alertInstance.visible = true;
    }*/

	function hide() {
        textArea.text = ""
        alertInstance.visible = false;
	}

    Rectangle {
        anchors.fill: parent
        color: "#a0404040"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (autoCloseOnClick) {
                alertInstance.visible = false;
            }
        }
    }

    Rectangle {
        anchors.fill: column
        anchors.margins: -Zc.AppStyleSheet.width(0.1)
        color: "white"
        radius: Zc.AppStyleSheet.width(0.04)
    }

    Column {
        id: column
        anchors.centerIn: parent
        width: Zc.AppStyleSheet.limitedWidth(2, alertInstance.width, 0.9)
        spacing: Zc.AppStyleSheet.height(0.08)

        Text {
            width: column.width
            text: alertInstance.title
            color: "black"
            font.bold: true
            font.pixelSize: Zc.AppStyleSheet.height(0.14)
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        TextArea {
            id : textArea
            width: column.width
            height : width * 4 /5
            font.pixelSize: Zc.AppStyleSheet.height(0.10)
            focus : true
        }

        /*Text {
            width: column.width
            text: alertInstance.message
            color: "black"
            font.pixelSize: Zc.AppStyleSheet.height(0.10)
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            visible: alertInstance.message !== ""
        }*/

        Item {
            width: column.width
            height: Zc.AppStyleSheet.height(0.08)
        }

        Rectangle {
            width: column.width
            height: 1
            anchors.margins: -100
            color: "#ccc"
        }

        RowLayout {
            width: column.width
            spacing: Zc.AppStyleSheet.width(0.08)

            Button {
                Layout.fillWidth: true
                text: alertInstance.button1
                visible: alertInstance.button1 !== ""
                style: OnCommentButtonStyle {
                	textColor: button1Color
				}
                onClicked: {
                    alertInstance.hide();
                //    alertInstance.button1Clicked();
                }
            }

            Button {
                Layout.fillWidth: true
                text: alertInstance.button2
                visible: alertInstance.button2 !== ""
                style: OnCommentButtonStyle {
                	textColor: button2Color
				}
                onClicked: {
                    message = textArea.text
                    alertInstance.hide();
                    alertInstance.addClicked();
                }
            }
        }
    }
}
