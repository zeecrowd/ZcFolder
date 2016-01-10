import QtQuick 2.5
import QtQuick.Controls 1.3

import ZcClient 1.0 as Zc

BusyIndicator {
    id : busyIndicator
    anchors.centerIn: parent
    anchors.verticalCenterOffset: -Zc.AppStyleSheet.height(0.2)
    running: false
    property bool cancellable : true
    style: BusyIndicatorStyle { }

    property string title: ""
}
