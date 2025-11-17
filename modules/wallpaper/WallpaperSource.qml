import QtQuick
import Quickshell
import qs

ShaderEffectSource {
    required property size resolution

    live: true
    sourceItem: Item {
        width: resolution.width
        height: resolution.height
        Image {
            id: wallpaperBack
            anchors.fill: parent
            source: Config.wallpaper
        }

        Image {
            id: wallpaperFront
            anchors.fill: parent
            source: ""
        }

        NumberAnimation {
            id: bgFade
            target: wallpaperFront
            properties: "opacity"
            from: 0
            to: 1
            duration: 500
        }
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
        onSetWallpaper: image => {
            wallpaperFront.source = image;
            bgFade.start();
            delay(1000, function() {
                Config.wallpaper = image;
                wallpaperFront.opacity = 0;
            })
        }
    }
}
