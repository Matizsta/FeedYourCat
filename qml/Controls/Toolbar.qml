import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import Singletons 1.0
import "." as Controls

ToolBar {
    id: root

    property QtObject stack

    state: stack.state
    states: [
        State {
            name: "mainMenu"

            PropertyChanges { target: root; visible: false }
        },
        State {
            name: "settings"

            PropertyChanges { target: root; visible: true }
        },
        State {
            name: "rules"

            PropertyChanges { target: root; visible: false }
        },
        State {
            name: "game"

            PropertyChanges { target: root; visible: true }
            PropertyChanges { target: scorePanel; visible: true }
            PropertyChanges { target: pauseButton; visible: true }
        },
        State {
            name: "score"

            PropertyChanges { target: root; visible: false }
        },
        State {
            name: "pause"

            PropertyChanges { target: root; visible: false }
        }
    ]

    background: null

    Rectangle {
        anchors.fill: parent
        color: ThemeManager.currentTheme["themeSwitcherCheckedColor"]
        opacity: ThemeManager.currentTheme["themeSwitcherOpacity"]
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: root.state === "game" ? root.width / 30 : 30
            rightMargin: root.state === "game" ? root.width / 30 : 30
        }

        BackToolButton {
            width: height * 14 / 20
            height: parent.height / 1.3
            onClicked: stack.pop()
        }

        Item {
            id: centerItem

            Layout.fillWidth: visible
            Layout.preferredHeight: root.height

            ScorePanel {
                id: scorePanel

                anchors.centerIn: parent

                visible: false
            }

            Controls.Label {
                id: titleLabel

                anchors.fill: parent
                horizontalAlignment: Qt.AlignRight
                verticalAlignment: Qt.AlignVCenter

                text: stack.currentItem && stack.currentItem.hasOwnProperty("title") ? stack.currentItem.title
                                                                                     : ""
                elide: Label.ElideRight
                color: ThemeManager.currentTheme["toolbarTextColor"]
            }
        }

        PauseToolButton {
            id: pauseButton

            width: height * 16 / 20
            height: parent.height / 1.3
            visible: false
            checked: Logic.sessionPaused

            onToggled: {
                Logic.sessionPaused ? Logic.pause()
                                    : Logic.resume()
            }
        }
    }
}
