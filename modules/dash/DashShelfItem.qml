import QtQuick
import Quickshell
import qs

Item {
    id: root
    required property int size
    required property var modelData
    required property var spacing

    implicitWidth: size * spacing
    implicitHeight: size - 6

    MouseArea {
        hoverEnabled: true

        anchors.fill: parent

        onEntered: {
            selectionBox.opacity = 1;
        }

        onExited: {
            selectionBox.opacity = 0;
        }

        onClicked: {
            modelData.execute();
            Config.dashAddRecentItem(modelData);
            GlobalState.sendCloseDash();
        }
    }

    Rectangle {
        id: selectionBox
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        implicitWidth: size - 50
        implicitHeight: size - 50
        color: "#40ffffff"
        radius: 3
        opacity: 0

        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }
    }

    Image {
        id: icon
        anchors.fill: selectionBox
        anchors.margins: 12
        source: Quickshell.iconPath(modelData.icon)
        fillMode: Image.PreserveAspectFit
        cache: false
        asynchronous: true
        sourceSize.width: selectionBox.width
        sourceSize.height: selectionBox.height
    }

    Text {
        anchors {
            top: selectionBox.bottom
            left: selectionBox.left
            right: selectionBox.right
        }
        text: modelData.name
        color: "white"
        font.family: "Ubuntu"
        maximumLineCount: 2
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        elide: Text.ElideRight
    }
}
