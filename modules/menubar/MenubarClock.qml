import QtQuick
import Quickshell
import qs

Text {
    anchors.centerIn: parent
    id: clockLabel
    font.family: "Ubuntu"
    text: Qt.formatDateTime(clock.date, "h:mm AP")
    color: Theme.menubar_fontColor
    font.pointSize: 11.5
    styleColor: "black"
    style: Text.Outline
    renderType: Text.QtRendering
    renderTypeQuality: 60

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
