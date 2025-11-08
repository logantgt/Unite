import QtQuick
import Quickshell
import qs

Item {
    id: root
    required property var iconSource
    required property var active

    signal clicked()

    Rectangle {
        id: bounds
        anchors.fill: parent
        color: "white"
        radius: 2
        opacity: 0
    }

    Image {
        anchors.centerIn: bounds
        width: 24
        height: width
        source: root.iconSource
        opacity: active ? 1 : 0.5
    }

    Image {
        anchors {
            top: bounds.top
            horizontalCenter: bounds.horizontalCenter
        }
        width: 8
        height: 5
        source: Config.themePath + "/icons/lens-button-active.svg"
        opacity: active ? 1 : 0
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            bounds.opacity = 0.25
        }

        onExited: {
            bounds.opacity = 0
        }

        onClicked: { root.clicked(); }
    }
}
