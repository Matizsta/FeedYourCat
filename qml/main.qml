import QtQuick 2.12
import QtQuick.Controls 2.12

import "controls" as Controls

ApplicationWindow {
    visible: true
    width: 480
    height: 640
    title: qsTr("Feed your cat")

    header: Controls.Toolbar {
        stack: stackView
    }

    PageSelector {
        id: stackView

        anchors.fill: parent
    }
}