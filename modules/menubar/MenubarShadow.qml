import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs

PanelWindow {
    property bool shouldShow: true
    anchors {
        top: true
        left: true
        right: true
    }

    margins.left: -Theme.taskbar_borderWidth

    implicitHeight: Theme.menubar_shadowHeight
    exclusiveZone: 0

    color: "transparent"

    Image {
        id: texture
        anchors.fill: parent
        source: Config.themePath + "/menubarShadow.svg"
        opacity: (shouldShow == false || (ToplevelManager.activeToplevel != null && ToplevelManager.activeToplevel.maximized == true && ToplevelManager.activeToplevel.minimized == false)) ? 0 : 1
        Behavior on opacity {
            NumberAnimation { duration: Theme.dash_animationDuration }
        }
    }

    Connections {
        target: GlobalState
        onDashOpened: { shouldShow = false; }
        onCloseDash: { shouldShow = true; }
    }
}
