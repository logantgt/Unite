import QtQuick
import QtQuick.Effects
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

    // color background
    ShaderEffectSource {
        id: backgroundSource
        sourceItem: {
            if(Config.autoSelectionColor) {
                return Qt.createQmlObject(`
                import QtQuick
                import QtQuick.Effects
                import qs
                import qs.modules.wallpaper

                ShaderEffect {
                    implicitWidth: 1
                    implicitHeight: 1
                    property var source: WallpaperSource {
                        resolution: Qt.size(root.width / 8, root.height / 8)
                    }
                    property real saturation: 0.65
                    property real value: 0.95
                    fragmentShader: "../../shaders/Quantize.frag"
                    visible: false
                }
                `, root, "wallpaperQuantize.qml")
            } else {
                return Qt.createQmlObject(`
                import QtQuick
                import qs

                Rectangle {
                    implicitWidth: 1
                    implicitHeight: 1
                    color: Config.selectionColor
                    layer.enabled: true
                    visible: false
                }
                `, root, "selectionColor.qml")
            }
        }
    }

    Rectangle {
        id: backingRect
        anchors.fill: parent
        anchors.margins: 1
        opacity: 0
        color: "white"

        BorderImage {
            id: backgroundImg
            layer.enabled: true
            anchors.fill: parent
            source: Config.themePath + "/menu_item_hover.svg"
            border { left: 10; top: 12; right: 10; bottom: 12 }
            visible: false
        }

        MultiEffect {
            id: background
            source: backgroundSource
            anchors.fill: parent
            maskEnabled: true
            maskSource: backgroundImg
            maskSpreadAtMin: 1
            maskSpreadAtMax: 1
            maskThresholdMin: 0.5
        }
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
        source: root.modelData.icon
        anchors {
            verticalCenter: parent.verticalCenter
            left: checkedIndicator.right
            leftMargin: 2
        }
        height: parent.height - 6
        width: height
        mipmap: true
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

        onEntered: { if(root.modelData.interactive) { backingRect.opacity = 1; } }
        onExited: { if(root.modelData.interactive) { backingRect.opacity = 0; } }
        onClicked: { if(root.modelData.interactive) { root.modelData.action(); GlobalState.sendCloseMenu(); } }
    }
}
