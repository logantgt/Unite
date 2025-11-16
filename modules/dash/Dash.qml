import QtQuick
import Quickshell
import Quickshell.Io
import qs

PanelWindow {
    id: dash

    anchors {
        top: true
        left: true
        bottom: true
        right: true
    }

    Component.onCompleted: {
        GlobalState.sendDashOpened()
        dashOpenFade.start()
    }

    Component.onDestruction: {
        GlobalState.sendDashClosed()
    }

    margins.left: -Theme.taskbar_borderWidth

    color: "transparent"

    focusable: true

    Connections {
        target: GlobalState
        onCloseDash: { dashCloseFade.start(); }
    }

    Item {
        id: dashContainer
        anchors.fill: parent
        opacity: 0

        MouseArea {
            anchors {
                top: parent.top
                right: parent.right
                bottom: parent.bottom
                left: dash_right_border_tile.right
            }
            onClicked: { GlobalState.sendCloseDash(); }
        }

        MouseArea {
            anchors {
                top: dash_bottom_border_tile.bottom
                right: parent.right
                bottom: parent.bottom
                left: parent.left
            }
            onClicked: { GlobalState.sendCloseDash(); }
        }

        NumberAnimation {
            id: dashOpenFade
            target: dashContainer
            property: "opacity"
            from: 0
            to: 1
            duration: Theme.dash_animationDuration
        }

        NumberAnimation {
            id: dashCloseFade
            target: dashContainer
            property: "opacity"
            from: 1
            to: 0
            duration: Theme.dash_animationDuration
        }

        Rectangle {
            id: dashBase
            implicitWidth: bestDashSize().width
            implicitHeight: bestDashSize().height
            color: "transparent"

            function bestDashSize() {
                this.width = 0;
                this.height = 0;

                if(Config.dashMaximized) {
                    this.width = dash.width;
                    this.height = dash.height;
                    return this;
                }

                if(Config.dashFullHeight) {
                    this.width = (dash.screen.width * (1 / 1.61803398875)) / 2;
                    this.height = dash.height;
                    return this;
                }

                // Greater than or equal to 1920x1080
                if(dash.screen.width >= 1920) {
                    // Ensure dash doesn't get wider than it would be allowed to on a 16:9 monitor on wider aspect ratios
                    if(dash.screen.width / dash.screen.height > (16 / 9)) {
                        this.width = Math.round((dash.screen.height * (16 / 9)) * (1 / 1.61803398875));
                    }
                    else {
                        this.width = Math.round(dash.screen.width * (1 / 1.61803398875));
                    }
                }

                if(dash.screen.height >= 1080) {
                    this.height = Math.round(dash.screen.height * (1 / 1.61803398875));
                }

                // Less than 1920x1080
                if(dash.screen.width < 1920) {
                    this.width = Math.round(dash.screen.width * (3 / 4));
                }

                if(dash.screen.height < 1080) {
                    this.height = Math.round(dash.screen.height * (3 / 4));
                }

                // Less than or equal to 1024x600
                if(dash.screen.width <= 1024) {
                    this.width = dash.width;
                }

                if(dash.screen.height <= 600) {
                    this.height = dash.height;
                }

                return this;
            }

            bottomRightRadius: Theme.dash_cornerRadius

            DashContent {
                anchors.fill: parent
                dashShelfItemSize: Config.dashShelfItemSize * (Math.floor(((this.width / Config.dashShelfItemSize) / Math.floor(this.width / Config.dashShelfItemSize)) * 100) / 100)
            }
        }

        Rectangle {
            anchors {
                top: dashBase.bottom
                left: parent.left
            }

            implicitWidth: Theme.dash_cornerRadius
            implicitHeight: Theme.dash_cornerRadius

            color: "transparent"

            ShaderEffect {
                anchors.fill: parent
                property var baseColor: Qt.darker(Config.accentColor, 1.3)
                property real curveRadius: 1
                property int curveOrientation: 3
                fragmentShader: "../../shaders/InverseCorner.frag"
            }
        }

        Image {
            id: dash_top_right_corner
            anchors {
                top: parent.top
                left: dashBase.right
                topMargin: -Theme.dash_borderDistance
                leftMargin: -Theme.dash_borderDistance
            }

            sourceSize.width: width
            sourceSize.height: height
            source: Config.themePath + "/dash/dash_top_right_corner.svg"
            smooth: false
        }

        Image {
            id: dash_right_border_tile
            anchors {
                top: dash_top_right_corner.bottom
                left: dashBase.right
                bottom: dashBase.botttom
                leftMargin: -Theme.dash_borderDistance
            }

            height: dashBase.height - dash_top_right_corner.height

            sourceSize.width: width
            source: Config.themePath + "/dash/dash_right_border_tile.svg"
            fillMode: Image.TileVertically
            smooth: false
        }

        Image {
            id: dash_top_tile
            anchors {
                top: parent.top
                left: dash_top_right_corner.right
                right: parent.right
                topMargin: -Theme.dash_borderDistance
            }
            sourceSize.height: height
            source: Config.themePath + "/dash/dash_top_tile.svg"
            fillMode: Image.TileHorizontally
            smooth: false
        }

        Image {
            id: dash_bottom_left_corner
            anchors {
                top: dashBase.bottom
                left: parent.left
                topMargin: -Theme.dash_borderDistance
                leftMargin: -Theme.dash_borderDistance
            }

            sourceSize.width: width
            sourceSize.height: height
            source: Config.themePath + "/dash/dash_bottom_left_corner.svg"
            smooth: false
        }

        Image {
            id: dash_bottom_border_tile
            anchors {
                top: dashBase.bottom
                left: dash_bottom_left_corner.right
                bottom: dash_bottom_left_corner.botttom
                topMargin: -Theme.dash_borderDistance
            }

            width: dashBase.width - dash_bottom_left_corner.width

            sourceSize.height: height
            source: Config.themePath + "/dash/dash_bottom_border_tile.svg"
            fillMode: Image.TileHorizontally
            smooth: false
        }

        Image {
            id: dash_bottom_right_corner
            anchors {
                top: dash_right_border_tile.bottom
                left: dash_bottom_border_tile.right
            }

            sourceSize.width: width
            sourceSize.height: height
            source: Config.themePath + "/dash/dash_bottom_right_corner.svg"
            smooth: false
        }

        Image {
            id: dash_left_tile
            anchors {
                top: dash_bottom_left_corner.bottom
                left: parent.left
                bottom: parent.bottom
                leftMargin: -Theme.dash_borderDistance
            }

            sourceSize.width: width
            source: Config.themePath + "/dash/dash_left_tile.svg"
            fillMode: Image.TileVertically
            smooth: false
        }
    }
}
