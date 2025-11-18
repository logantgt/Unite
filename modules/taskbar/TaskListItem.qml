import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs
import qs.modules.popups

Item {
    id: root
    required property var modelData
    required property int size
    property bool running: modelData.toplevels.length > 0 ? true : false
    property bool focused: modelData.activated

    implicitWidth: size
    implicitHeight: size

    // Quantize
    ShaderEffectSource {
        id: backgroundSource
        sourceItem: ShaderEffect {
            implicitWidth: 1
            implicitHeight: 1
            property var source: Image { source: taskIcon.source }
            property real saturation: 0.75
            fragmentShader: "../../shaders/Quantize.frag"
            visible: false
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
        property real baseOpacity: running? 0.5 : 0
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
        anchors.margins: Theme.tasklistitem_itemMargins
        source: Config.themePath + "/taskItem.svg"
        smooth: false
    }

    // Running Indicator
    Image {
        id: themeTaskItemRunning
        anchors.fill: parent
        source: Config.themePath + "/taskItemRunning.svg"
        opacity: running ? 1 : 0
    }

    // Focused Indicator
    Image {
        id: themeTaskItemFocused
        anchors.fill: parent
        source: Config.themePath + "/taskItemFocused.svg"
        opacity: focused ? 1 : 0
    }

    // App Icon
    IconImage {
        id: taskIcon
        anchors.fill: parent
        anchors.margins: Theme.tasklistitem_iconMargins + Theme.tasklistitem_itemMargins
        source: Quickshell.iconPath(DesktopEntries.heuristicLookup(modelData.appId).icon)
        z: 10
    }

    PopupTooltip {
        id: tooltip
        text: DesktopEntries.heuristicLookup(modelData.appId).name
        textColor: Theme.tasklistitem_tooltipTextColor
        opacity: 0
    }

    MouseArea {
        id: hoverEffectMouseArea
        anchors.fill: parent
        hoverEnabled: true

        // tooltip timer
        Timer {
            id: tooltipTimer
            interval: 1000;
            running: false;
            onTriggered: tooltip.opacity = 1;
        }

        onEntered: {
            if(Theme.tasklistitem_hotTrack) glow.glowOpacity = 1;
            tooltipTimer.running = true;
        }
        onExited: {
            glow.glowOpacity = 0;
            tooltip.opacity = 0;
            tooltipTimer.running = false;
        }
    }

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if(mouse.button == Qt.LeftButton) {
                if(root.modelData.toplevels.length > 0) {
                    if(root.modelData.activeIndex > -1 && root.modelData.activeIndex + 1 < root.modelData.toplevels.length) {
                        root.modelData.toplevels[root.modelData.activeIndex + 1].activate();
                    }
                    else {
                        root.modelData.toplevels[0].activate();
                    }
                }
                else {
                    DesktopEntries.heuristicLookup(modelData.appId).execute();
                }
            }
            else if(mouse.button == Qt.RightButton && root.modelData.toplevels.length > 0) {
                DesktopEntries.heuristicLookup(modelData.appId).execute();
            }

            flashAnimationBase.start();
            flashAnimationGlow.start();

            GlobalState.sendCloseMenu();
            GlobalState.sendCloseDash();
        }
    }
}
