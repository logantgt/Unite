pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs

Singleton {
    id: settings
    // Signals dispatched by the dash
    signal dashOpened()
    signal dashClosed()

    function sendDashOpened() {
        dashOpened()
    }

    function sendDashClosed() {
        dashClosed()
    }

    // Signals dispatched by callers
    signal closeDash()

    function sendCloseDash() {
        closeDash()
    }

    signal setWallpaper(image: string)

    function sendSetWallpaper(image) {
        setWallpaper(image)
    }

    IpcHandler {
        target: "settings"

        function setWallpaper(image: string): void {
            settings.setWallpaper(image)
        }

        function getWallpaper(): string {
            return Config.wallpaper
        }
    }
}
