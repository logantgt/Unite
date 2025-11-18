import QtQuick
import Quickshell
import qs

Rectangle {
    id: root
    required property var modelData
    // modelData.text (string) - main text of the menu item
    // modelData.hint (string) - hint text of the menu item
    // modelData.icon (string) - path to icon of the menu item
    // modelData.selected (bool) - whether or not the menu item has a selected indicator (radio button)
    // modelData.checked (bool) - whether or not the menu item has a checked indicator (check box)
    // modelData.source (string) - the Component to load and child to the menu item, if not null (above values should not be set)
    // modelData.interactive (bool) - whether or not the menu item can be highlighted/clicked
    // modelData.action (function) - the action attached to this menu item, executed on click

    color: "transparent"

    implicitHeight: 24

    BorderImage {
        id: background
        anchors.fill: parent
        source: Config.themePath + "/menu_item_hover.svg"
        border { left: 10; top: 12; right: 10; bottom: 12 }
        opacity: 0
    }

    Image {
        id: selectedIndicator
        source: Config.themePath + "/menu_item_selected.svg"
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 4
        }
        height: parent.height
        width: height
        opacity: root.modelData.selected ? 1 : 0
    }

    Image {
        id: checkedIndicator
        source: Config.themePath + "/menu_item_checked.svg"
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 4
        }
        height: parent.height
        width: height
        opacity: root.modelData.checked ? 1 : 0
    }

    Image {
        id: icon
        source: root.modelData.icon == "" ? "" : Quickshell.iconPath(root.modelData.icon)
        anchors {
            verticalCenter: parent.verticalCenter
            left: checkedIndicator.right
            leftMargin: 2
        }
        height: parent.height - 6
        width: height
    }

    Text {
        id: mainText
        anchors {
            verticalCenter: parent.verticalCenter
            left: root.modelData.icon == "" ? checkedIndicator.right : icon.right
            leftMargin: 6
        }

        text: root.modelData.text
        color: root.modelData.interactive ? Theme.menubar_fontColor : Qt.darker(Theme.menubar_fontColor, 1.5)
        style: Text.Sunken
        font.family: "Ubuntu"
        font.pointSize: 11
    }

    Text {
        id: hintText
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 10
        }

        text: root.modelData.hint
        color: Qt.darker(Theme.menubar_fontColor, 1.5)
        style: Text.Sunken
        font.family: "Ubuntu"
        font.pointSize: 11
    }

    Loader {
        id: childLoader
        anchors {
            left: parent.left
            right: parent.right
        }
        source: root.modelData.source
        active: root.modelData.source == null ? false : true

        onLoaded: { root.implicitHeight = childLoader.item.height }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true

        onEntered: { if(root.modelData.interactive) { background.opacity = 1; } }
        onExited: { if(root.modelData.interactive) { background.opacity = 0; } }
        onClicked: { if(root.modelData.interactive) { root.modelData.action(); GlobalState.sendCloseMenu(); } }
    }
}
