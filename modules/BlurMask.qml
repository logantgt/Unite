import QtQuick
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

    Item {
        id: maskLayer
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
            color: Config.accentColor
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
            color: Config.accentColor
        }

        // Dash rectangle
        Rectangle {
            id: dashMask
            anchors {
                top: menubarMask.bottom
                left: taskbarMask.right
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
            bottomRightRadius: 8
            opacity: 0
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.dash_animationDuration / 10
                }
            }
            color: Config.accentColor
        }
    }

    Connections {
        target: GlobalState
        onDashOpened: {
            dashMask.opacity = 1;
        }
        onDashClosed: {
            dashMask.opacity = 0;
        }
    }
}
