import QtQuick
import QtQuick.Effects
import Quickshell
import qs

PanelWindow {
    required property var items
    required property int menuWidth

    anchors {
        top: true
        right: true
        left: true
        bottom: true
    }

    color: "transparent"

    BorderImage {
        id: background
        anchors {
            top: parent.top
            right: parent.right
        }
        width: menuWidth
        height: menuBase.height

        source: Config.themePath + "/menu.svg"
        border { left: 10; top: 10; right: 10; bottom: 10 }
    }

    MouseArea {
        anchors {
            top: parent.top
            right: background.left
            bottom: parent.bottom
            left: parent.left
        }
        onClicked: { GlobalState.sendCloseMenu(); }
    }

    MouseArea {
        anchors {
            top: background.bottom
            right: parent.right
            bottom: parent.bottom
            left: parent.left
        }
        onClicked: { GlobalState.sendCloseMenu(); }
    }

    MultiEffect {
        source: background
        anchors.fill: background
        shadowEnabled: true
        shadowHorizontalOffset: 5
        shadowVerticalOffset: 5
        shadowScale: 0.95
    }

    Column {
        id: menuBase
        anchors {
            top: background.top
            left: background.left
            right: background.right
        }
        Repeater {
            id: menu
            model: items

            MenuItem {
                width: parent.width
            }
        }
    }
}
