import QtQuick
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

    Image {
        id: wallpaper
        anchors.fill: parent
        source: Config.wallpaper
        fillMode: Image.PreserveAspectCrop
    }

    WlrLayershell.layer: WlrLayer.Background

    exclusionMode: ExclusionMode.Ignore

    Component.onCompleted: {
        if (this.WlrLayershell != null) {
          this.WlrLayershell.layer = WlrLayer.Background;
        }
    }
}
