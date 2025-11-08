import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs

ScrollView {
    required property var taskItemSpacing
    required property int size

    id: root
    ScrollBar.vertical.policy: ScrollBar.AlwaysOff
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    contentWidth: availableWidth
    implicitWidth: root.size

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: root.taskItemSpacing
        spacing: root.taskItemSpacing

        Repeater {
            model: aggregateToplevels(ToplevelManager.toplevels)

            TaskListItem {
                size: parent.width
            }
        }
    }

    function aggregateToplevels(input) {
        let results = []

        for(let i = 0; i < Config.taskbarPinnedItems.length; i++) {
            let found = {}

            found.appId = Config.taskbarPinnedItems[i];
            found.toplevels = input.values.filter(item => item.appId === Config.taskbarPinnedItems[i]);
            found.activated = input.values.filter(item => item.activated == true && item.appId === Config.taskbarPinnedItems[i]).length > 0 ? true : false
            found.activeIndex = found.toplevels.findIndex(item => item.activated == true);

            results.push(found);
        }

        for(let i = 0; i < input.values.length; i++) {
            if(!results.some(item => item.appId === input.values[i].appId)) {
                let found = {}

                found.appId = input.values[i].appId;
                found.toplevels = input.values.filter(item => item.appId === input.values[i].appId);
                found.activated = input.values.filter(item => item.activated == true && item.appId === input.values[i].appId).length > 0 ? true : false
                found.activeIndex = found.toplevels.findIndex(item => item.activated == true);

                results.push(found);
            }
        }

        return results;
    }
}
