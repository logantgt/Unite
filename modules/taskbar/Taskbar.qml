import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs
import qs.modules.dash

PanelWindow {
    id: root

    // Dash Loader
    LazyLoader {
        id: dashLoader
        loading: false
        Dash {}
    }

    Timer {
        id: timer
    }

    function delay(delayTime, cb) {
        timer.interval = delayTime;
        timer.repeat = false;
        timer.triggered.connect(cb);
        timer.start();
    }

    Connections {
        target: GlobalState
        onCloseDash: {
            delay(Theme.dash_animationDuration, function() { dashLoader.active = false; })
        }
    }

    anchors {
        top: true
        left: Config.taskbarPosition === "left" ? true : false
        right: Config.taskbarPosition === "right" ? true : false
        bottom: true
    }

    implicitWidth: Theme.taskbar_width + Theme.taskbar_borderWidth
    color: "transparent"

    // Taskbar Border
    Rectangle {
        id: taskbarBorder
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: Config.taskbarPosition === "left" ? parent.right : undefined
            left: Config.taskbarPosition === "right" ? parent.left : undefined
        }

        implicitWidth: Theme.taskbar_borderWidth
        color: Theme.taskbar_borderColor

        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }
    }

    // Taskbar
    Rectangle {
        id: taskbar
        anchors.fill: parent
        anchors.rightMargin: Config.taskbarPosition == "left" ? Theme.taskbar_borderWidth : 0
        anchors.leftMargin: Config.taskbarPosition == "right" ? Theme.taskbar_borderWidth : 0
        implicitWidth: Theme.taskbar_width
        color: Config.useBlurMask ? "transparent" : Config.accentColor
        opacity: Theme.taskbar_opacity

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: { taskList.opacity = 1; }
            onExited: { if(dashLoader.active) taskList.opacity = 0.2; }

            Column {
                anchors.fill: parent

                // Dash Button
                DashButton {
                    size: taskbar.width

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if(!dashLoader.active) {
                                dashLoader.loading = true;
                            }
                            else { GlobalState.sendCloseDash() }
                        }
                    }
                }

                // Task List
                TaskList {
                    id: taskList
                    size: taskbar.width
                    taskItemSpacing: Theme.taskbar_taskItemSpacing
                    opacity: 1

                    Behavior on opacity {
                        NumberAnimation { duration: 100 }
                    }

                    Connections {
                        target: GlobalState
                        onDashOpened: { taskbarBorder.opacity = 0; }
                        onDashClosed: { taskList.opacity = 1; taskbarBorder.opacity = 1; }
                    }
                }
            }
        }
    }
}
