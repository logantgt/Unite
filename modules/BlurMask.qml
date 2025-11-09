import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs

PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
    exclusionMode: ExclusionMode.Ignore
    mask: Region {}
    color: "transparent"
    WlrLayershell.namespace: "unityShellBlurMask"

    ShaderEffectSource {
        id: wallpaperQuantize
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
                    property real saturation: 1
                    property real value: 1
                    fragmentShader: "../shaders/Quantize.frag"
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
                    color: Config.accentColor
                    layer.enabled: true
                    visible: false
                }
                `, root, "accentColor.qml")
            }
        }
    }

    Item {
        id: maskLayer
        visible: false
        anchors.fill: parent
        layer.enabled: true

        // Taskbar rectangle
        Rectangle {
            id: taskbarMask
            anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
            }

            implicitWidth: Theme.taskbar_width
            color: "white"
        }

        // Menubar rectangle
        Rectangle {
            id: menubarMask
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            implicitHeight: Theme.menubar_height
            color: "white"
        }

        // Dash rectangle
        Rectangle {
            id: dashMask
            anchors {
                top: menubarMask.bottom
                left: taskbarMask.right
            }

            NumberAnimation {
                id: dashOpenAnimation
                target: dashMask
                property: "opacity"
                from: 0
                to: 1
                duration: Theme.dash_animationDuration
            }

            NumberAnimation {
                id: dashCloseAnimation
                target: dashMask
                property: "opacity"
                from: 1
                to: 0
                duration: Theme.dash_animationDuration
            }

            function bestDashSize() {
                this.width = 0;
                this.height = 0;

                if(Config.dashMaximized) {
                    this.width = root.width;
                    this.height = root.height;
                    return this;
                }

                if(Config.dashFullHeight) {
                    this.width = (root.screen.width * (1 / 1.61803398875)) / 2;
                    this.height = root.height;
                    return this;
                }

                // Greater than or equal to 1920x1080
                if(root.screen.width >= 1920) {
                    // Ensure dash doesn't get wider than it would be allowed to on a 16:9 monitor on wider aspect ratios
                    if(root.screen.width / root.screen.height > (16 / 9)) {
                        this.width = Math.round((root.screen.height * (16 / 9)) * (1 / 1.61803398875));
                    }
                    else {
                        this.width = Math.round(root.screen.width * (1 / 1.61803398875));
                    }
                }

                if(root.screen.height >= 1080) {
                    this.height = Math.round(root.screen.height * (1 / 1.61803398875));
                }

                // Less than 1920x1080
                if(root.screen.width < 1920) {
                    this.width = Math.round(root.screen.width * (3 / 4));
                }

                if(root.screen.height < 1080) {
                    this.height = Math.round(root.screen.height * (3 / 4));
                }

                // Less than or equal to 1024x600
                if(root.screen.width <= 1024) {
                    this.width = root.width;
                }

                if(root.screen.height <= 600) {
                    this.height = root.height;
                }

                return this;
            }

            implicitWidth: bestDashSize().width
            implicitHeight: bestDashSize().height
            bottomRightRadius: Theme.dash_outerCornerRadius
            opacity: 0
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.dash_animationDuration
                }
            }
            color: "white"
        }

        Rectangle {
            anchors {
                top: menubarMask.bottom
                left: dashMask.right
            }

            implicitWidth: Theme.dash_cornerRadius
            implicitHeight: Theme.dash_cornerRadius

            color: "transparent"

            ShaderEffect {
                anchors.fill: parent
                property color baseColor: "white"
                property real curveRadius: 1
                property int curveOrientation: 3
                fragmentShader: "../shaders/InverseCorner.frag"
                opacity: dashMask.opacity
            }
        }

        Rectangle {
            anchors {
                top: dashMask.bottom
                left: taskbarMask.right
            }

            implicitWidth: Theme.dash_cornerRadius
            implicitHeight: Theme.dash_cornerRadius

            color: "transparent"

            ShaderEffect {
                anchors.fill: parent
                property color baseColor: "white"
                property real curveRadius: 1
                property int curveOrientation: 3
                fragmentShader: "../shaders/InverseCorner.frag"
                opacity: dashMask.opacity
            }
        }
    }

    MultiEffect {
        anchors.fill: parent
        source: wallpaperQuantize
        maskEnabled: true
        maskSource: maskLayer
        maskSpreadAtMin: 1
        maskSpreadAtMax: 1
        maskThresholdMin: 0.5
        opacity: Config.autoAccentColor ? 0.75 : 1
        brightness: Config.autoAccentColor ? -0.25 : 0
        saturation: Config.autoAccentColor ? -0.75 : 0
    }

    Connections {
        target: GlobalState
        onDashOpened: {
            dashOpenAnimation.start();
        }
        onCloseDash: {
            dashCloseAnimation.start();
        }
    }
}
