import QtQuick 2.12
import QtGraphicalEffects 1.12

import "../helpers/Constants.js" as Constants
import Singletons 1.0

MouseArea {
    id: root

    property int cellIndex: -1
    property int backgroundIndex: 0
    property string backgroundColor: Constants.catBackgrounds[backgroundIndex] || ThemeManager.currentTheme["cellBackgroundColor"]
    property real backgroundOpacity: 1
    property string borderColor: Constants.catBorders[backgroundIndex] || ThemeManager.currentTheme["cellBorderColor"]

    property bool isFed: false

    height: width

    state: !Logic.session || Logic.session.area[cellIndex] === 0 ? "nothing"
                                                                 : Logic.session.area[cellIndex] > 0 ? "cat"
                                                                                                     : "tiger"

    states: [
        State {
            name: "nothing"
            PropertyChanges {
                target: root
                backgroundColor: ThemeManager.currentTheme["cellBackgroundColor"]
                backgroundOpacity: ThemeManager.currentTheme["cellBackgroundOpacity"]
                borderColor: ThemeManager.currentTheme["cellBorderColor"]
            }
        },
        State {
            name: "cat"

            PropertyChanges { target: root; backgroundIndex: Math.floor(Math.random() * 7) }
        },
        State {
            name: "tiger"

            PropertyChanges { target: root; backgroundIndex: Math.floor(Math.random() * 7) }
        }
    ]

    onStateChanged: {
        isFed = false;
        if (state !== "nothing") {
            if (!Logic.session.isTestMode) {
                waitTimer.interval = Math.floor(Math.random() * (Logic.session.maximumCatDelay - Logic.session.minimumCatDelay)) + Logic.session.minimumCatDelay;
                waitTimer.start()
            }
        }
    }

    onClicked: {
        if (Logic.sessionPaused)
            return;

        if (!Logic.session.isTestMode) {
            if (waitTimer.running) {
                waitTimer.stop();
            }
            if (state !== "nothing")
                Vibrator.vibrate(120)
            isFed = true;
            catImage.hide(isFed);
        } else {
            if (state !== "nothing") {
                catImage.hide(isFed);
            } else {
                if (Logic.session.isTestMode) {
                    Logic.session.area[root.cellIndex] = root.cellIndex - 2;
                    Logic.session.areaChanged()
                }
            }
        }
    }

    AdvancedTimer {
        id: waitTimer

        onTriggered: {
            catImage.hide(isFed);
        }
    }

    Connections {
        target: Logic.session

        onPause: {
            if (waitTimer.running)
                waitTimer.pause()
        }
        onResume: {
            if (root.state !== "nothing")
                waitTimer.resume()
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 10

        color: root.backgroundColor
        opacity: root.backgroundOpacity

        Behavior on color {
            ColorAnimation {
                duration: 300
            }
        }
    }


    Image {
        id: mask
        anchors.fill: parent
        visible: false

        source: "../../resources/icons/mask.svg"
    }

    CatImage {
        id: catImage

        anchors.fill: parent
        visible: false

        catObject: root.state === "cat" ? Constants.catsCatalog[Logic.session.area[cellIndex] - 1] :
                                          root.state === "tiger" ? Constants.tigersCatalog[Math.abs(Logic.session.area[cellIndex]) - 1]
                                                                 : {}
        onHideAnimationFinished: {
            Logic.session.hideCat(root.cellIndex, root.isFed);
        }
        onShowAnimationFinished: {
            if (!Logic.session.isTestMode && root.state !== "nothing") {
                waitTimer.interval = Math.floor(Math.random() * (Logic.session.maximumCatDelay - Logic.session.minimumCatDelay)) + Logic.session.minimumCatDelay;
                waitTimer.start()
            }
        }

        Item {
            id: clickReactionImage

            anchors {
                fill: catImage
            }
            visible: root.state === "cat" || root.state === "tiger"
            //        opacity: 0

            Rectangle {
                anchors.fill: parent
                color: "#000000"
                opacity: 0.9
            }

            Image {
                anchors.fill: parent
                anchors.margins: 10
                sourceSize.width: width
                sourceSize.height: height

                source: "../../resources/icons/%1.svg".arg(root.state === "cat" ? "paw" : "jaws")
            }
        }
    }

    OpacityMask {
        anchors.fill: parent
        source: catImage
        maskSource: mask

        visible: root.state !== "nothing"
    }

    Rectangle {
        anchors.fill: parent

        radius: height / 10
        color: "transparent"
        border.color: root.borderColor
        border.width: 2
    }

}
