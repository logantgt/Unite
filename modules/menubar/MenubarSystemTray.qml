import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Row {
    spacing: 0
    Repeater {
        model: SystemTray.items.values.filter(item => item.Status !== Status.Passive)

        MenubarSystemTrayIcon {
            width: parent.height + 4
            height: parent.height
        }
    }
}
