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

    Image {
        id: wallpaper
        anchors.fill: parent
        source: Config.wallpaper
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: width / 8
        sourceSize.height: height / 8
        visible: false
    }

    MultiEffect {
        id: wallpaperBlur
        anchors.fill: wallpaper
        source: wallpaper
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
