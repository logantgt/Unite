import QtQuick
import Quickshell
import qs

Item {
    id: root
    property var text
    property var subText
    property var interactive
    property var iconSource
    signal clicked()
    implicitHeight: 34

    Rectangle {
        id: hoverHighlight
        color: "white"
        radius: 3
        anchors.fill: parent
        anchors.margins: 6
        opacity: 0
    }

    Image {
        id: icon
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }
        anchors.leftMargin: 14
        source: root.iconSource
        fillMode: Image.PreserveAspectFit
    }

    Text {
        id: headerText
        anchors {
            top: parent.top
            left: icon.right
            bottom: parent.bottom
        }
        leftPadding: 8
        text: root.text
        color: "white"
        font.family: "Ubuntu"
        font.pointSize: 14
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        anchors {
            top: parent.top
            left: headerText.right
            bottom: parent.bottom
        }
        topPadding: font.pointSize / 2
        leftPadding: 10
        text: root.subText
        opacity: 0.5
        color: "white"
        font.family: "Ubuntu"
        font.pointSize: 10
        font.weight: 500
        verticalAlignment: Text.AlignVCenter
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            if(root.interactive) hoverHighlight.opacity = 0.25
        }

        onExited: {
            if(root.interactive) hoverHighlight.opacity = 0
        }

        onClicked: {
            if(root.interactive) root.clicked();
        }
    }
}
