import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Row {
    Repeater {
        model: SystemTray.items.values.filter(item => item.Status !== Status.Passive)

        MenubarSystemTrayIcon {
            width: parent.height
            height: parent.height
        }
    }
}
