import QtQuick
import Quickshell
import qs

PopupBase {
    id: tooltip
    required property string text
    required property color textColor

    targetWidget: root
    implicitWidth: label.width + 16
    implicitHeight: label.height + 10
    padding: 5
    extendFrom: Config.taskbarPosition == "left" ? Edges.Left : Edges.Right
    mask: Region {}
    opacity: 1

    Behavior on opacity {
        NumberAnimation { duration: 150 }
    }

    Text {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        text: tooltip.text
        color: tooltip.textColor
    }
}
