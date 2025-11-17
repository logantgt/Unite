import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs

PanelWindow {
    required property var modelData
    screen: modelData
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    MultiEffect {
        anchors.fill: parent
        source: WallpaperSource {
            resolution: Qt.size(modelData.width, modelData.height)
            textureSize.width: parent.width / 4
            textureSize.height: parent.height / 4
        }
        autoPaddingEnabled: false
        blurEnabled: true
        blur: 1.0
        blurMax: 64
    }

    Rectangle {
        anchors.fill: parent
        color: "#7f000000"
    }

    WlrLayershell.namespace: "quickshell.overviewWallpaper"

    WlrLayershell.layer: WlrLayer.Background

    exclusionMode: ExclusionMode.Ignore

    Component.onCompleted: {
        if (this.WlrLayershell != null) {
          this.WlrLayershell.layer = WlrLayer.Background;
        }
    }
}
