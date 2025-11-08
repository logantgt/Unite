import QtQuick
import Quickshell

PanelWindow {
    implicitWidth: 400
    implicitHeight: 400
    color: "transparent"
    BorderImage {
        anchors { fill: parent; }
        border { left: 14; top: 14; right: 14; bottom: 14 }
        horizontalTileMode: BorderImage.Repeat
        verticalTileMode: BorderImage.Repeat
        source: Config.themePath + "/modalFrame.svg"
    }

    Rectangle {
        anchors.fill: parent
        color: Config.accentColor
        anchors.margins: 10
        radius: 4.5
    }
}
