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

    // this is dumb
    MultiEffect {
        anchors.fill: parent
        source: WallpaperSource {
            resolution: Qt.size(modelData.width, modelData.height)
        }
        autoPaddingEnabled: false
        blurEnabled: false
    }

    WlrLayershell.layer: WlrLayer.Background

    exclusionMode: ExclusionMode.Ignore

    Component.onCompleted: {
        if (this.WlrLayershell != null) {
          this.WlrLayershell.layer = WlrLayer.Background;
        }
    }
}
