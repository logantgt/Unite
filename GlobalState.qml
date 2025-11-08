pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
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
}
