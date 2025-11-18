import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.modules

PanelWindow {
    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Theme.menubar_height

    color: "transparent"
    mask: Region {}

    // Menu Models
    ListModel {
        id: sessionMenuModel
        ListElement { text: "About This Computer"; hint: ""; icon: ""; selected: false; checked: false; source: null;  interactive: true; action: () => {}; }
        ListElement { text: "Ubuntu Help..."; hint: ""; icon: ""; selected: false; checked: false; source: null;  interactive: true; action: () => {}; }
        ListElement { text: ""; hint: ""; icon: ""; selected: false; checked: false; source: "MenuSplitter.qml";  interactive: false; action: () => {}; }
        ListElement { text: "System Settings"; hint: ""; icon: ""; selected: false; checked: false; source: null;  interactive: true; action: () => {}; }
        ListElement { text: ""; hint: ""; icon: ""; selected: false; checked: false; source: "MenuSplitter.qml";  interactive: false; action: () => {}; }
        ListElement { text: "Lock"; hint: "Ctrl+Alt+L"; icon: ""; selected: false; checked: false; source: null;  interactive: true; action: () => {}; }
        ListElement { text: ""; hint: ""; icon: ""; selected: false; checked: false; source: "MenuSplitter.qml";  interactive: false; action: () => {}; }
        ListElement { text: "Log Out..."; hint: ""; icon: ""; selected: false; checked: false; source: null;  interactive: true; action: () => {}; }
        ListElement { text: ""; hint: ""; icon: ""; selected: false; checked: false; source: "MenuSplitter.qml";  interactive: false; action: () => {}; }
        ListElement { text: "Suspend"; hint: ""; icon: ""; selected: false; checked: false; source: null;  interactive: true; action: () => {}; }
        ListElement { text: "Shut Down..."; hint: ""; icon: ""; selected: false; checked: false; source: null;  interactive: true; action: () => {}; }
    }

    // Menu Loader
    LazyLoader {
        id: menuLoader
        loading: false
        Menu {
            items: sessionMenuModel
            menuWidth: 250
        }
    }

    Connections {
        target: GlobalState
        onCloseMenu: {
            menuLoader.active = false;
        }
    }

    Rectangle {
        id: bar
        anchors.fill: parent
        color: "transparent"

        Behavior on color {
            ColorAnimation { duration: 0 }
        }

        Image {
            id: texture
            anchors.fill: parent
            source: Config.themePath + "/menubar.svg"
            opacity: Theme.menubar_opacity
            Behavior on opacity {
                NumberAnimation { duration: Theme.dash_animationDuration }
            }
        }

        Connections {
            target: GlobalState
            onDashOpened: {
                texture.opacity = 0;
                windowTitleLabel.opacity = 0;
                contentColorize.colorizationColor = "white";
                windowButtons.opacity = 1;
            }
            onCloseDash: {
                texture.opacity = Theme.menubar_opacity;
                windowTitleLabel.opacity = 1;
                contentColorize.colorizationColor = Theme.menubar_fontColor;
                windowButtons.opacity = 0;
            }
        }

        Item {
            id: windowButtons
            anchors.fill: parent
            anchors.leftMargin: 4
            opacity: 0;

            Row {
                anchors.fill: parent
                Image {
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                    source: Config.themePath + "/icons/close_dash.svg"
                }

                Image {
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                    source: Config.themePath + "/icons/minimize_dash_disabled.svg"
                }

                Image {
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                    source: Config.dashMaximized ? Config.themePath + "/icons/unmaximize_dash.svg" : Config.themePath + "/icons/unmaximize_dash.svg"
                }
            }

            Behavior on opacity {
                NumberAnimation { duration: Theme.dash_animationDuration }
            }
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Spacer { size: 6 }

            Text {
                id: windowTitleLabel
                anchors.verticalCenter: parent.verticalCenter
                font.weight: 600
                font.family: "Ubuntu"
                font.pointSize: 11.5
                styleColor: "black"
                style: Text.Outline
                text: ToplevelManager.activeToplevel != null ? ToplevelManager.activeToplevel.title : Config.desktopName
                color: Theme.menubar_fontColor
                renderType: Text.QtRendering
                renderTypeQuality: 60

                Behavior on opacity {
                    NumberAnimation { duration: Theme.dash_animationDuration }
                }
            }

            Spacer {
                size: 1
                Layout.fillWidth: true
            }

            Spacer {
                size: 6
            }

            SystemClock {
                id: clock
                precision: SystemClock.Seconds
            }

            Text {
                id: clockLabel
                font.family: "Ubuntu"
                text: Qt.formatDateTime(clock.date, "h:mm AP")
                color: Theme.menubar_fontColor
                font.pointSize: 11.5
                styleColor: "black"
                style: Text.Outline
                renderType: Text.QtRendering
                renderTypeQuality: 60
            }

            Spacer {
                size: 6
            }

            Item {
                implicitWidth: Theme.menubar_height
                implicitHeight: Theme.menubar_height
                Image {
                    id: sessionIcon
                    source: Config.themePath + "/session.svg"
                    anchors.fill: parent
                    anchors.margins: 2
                }

                MultiEffect {
                    id: contentColorize
                    source: sessionIcon
                    anchors.fill: sessionIcon
                    colorization: 1.0
                    colorizationColor: Theme.menubar_fontColor

                    Behavior on colorizationColor {
                        ColorAnimation { duration: Theme.dash_animationDuration }
                    }
                }
            }

            Spacer {
                size: 3
            }
        }
    }
}
