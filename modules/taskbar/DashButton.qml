import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs

Item {
    id: root
    required property int size

    implicitWidth: size
    implicitHeight: size

    // color background
    ShaderEffectSource {
        id: backgroundSource
        sourceItem: {
            if(Config.autoAccentColor) {
                return Qt.createQmlObject(`
                import QtQuick
                import QtQuick.Effects
                import qs

                ShaderEffect {
                    implicitWidth: 1
                    implicitHeight: 1
                    property var source: Image { source: Config.wallpaper }
                    property real saturation: 0.65
                    property real value: 1
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
                    color: Qt.lighter(Qt.rgba(Config.accentColor.r, Config.accentColor.g, Config.accentColor.b, 1), 3.5)
                    layer.enabled: true
                    visible: false
                }
                `, root, "accentColor.qml")
            }
        }
    }

    // Glow
    ShaderEffect {
        id: glow
        anchors.fill: parent
        fragmentShader: "../../shaders/TaskIconGlow.frag"
        property var source: backgroundSource
        property var mask: Image { source: Config.themePath + "/taskItemMask.svg" }
        property vector2d glowOrigin: Qt.vector2d(hoverEffectMouseArea.mouseX / width, hoverEffectMouseArea.mouseY / height)
        property real glowRadius: 1
        property real baseOpacity: 0.5
        property real glowOpacity: 0
        visible: true

        NumberAnimation {
            id: flashAnimationBase
            target: glow
            property: "baseOpacity"
            from: 0
            to: 0.5
            duration: 150
        }

        NumberAnimation {
            id: flashAnimationGlow
            target: glow
            property: "glowOpacity"
            from: 0
            to: 1
            duration: 150
        }

        Behavior on baseOpacity {
            NumberAnimation { duration: 100 }
        }

        Behavior on glowOpacity {
            NumberAnimation { duration: 100 }
        }
    }

    // Main image
    Image {
        id: themeTaskItem
        anchors.fill: parent
        source: Config.themePath + "/taskItem.svg"
        smooth: false
    }

    // Focused Indicator
    Image {
        id: themeTaskItemFocused
        anchors.fill: parent
        source: Config.themePath + "/taskItemFocused.svg"
        opacity: 0
    }

    // App Icon
    Image {
        id: taskIcon
        anchors.fill: parent
        source: Config.themePath + "/dashButton.svg"
        mipmap: true
        z: 10
    }

    MouseArea {
        id: hoverEffectMouseArea
        anchors.fill: parent
        hoverEnabled: true

        onEntered: { if(Theme.tasklistitem_hotTrack) glow.glowOpacity = 1; }
        onExited: { glow.glowOpacity = 0; }
    }

    Connections {
        target: GlobalState
        onDashOpened: { themeTaskItemFocused.opacity = 1; }
        onDashClosed: { themeTaskItemFocused.opacity = 0; }
    }
}
