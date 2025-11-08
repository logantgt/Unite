import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs

Item {
    id: root
    property var dashShelfItemSize

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        DashSearch {
            id: searchBar
            Layout.preferredHeight: 54
            Layout.fillWidth: true
            placeholderText: "Search applications"
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

                DashShelf {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    headerText: "Applications"
                    iconSource: Config.themePath + "/icons/lens-nav-app.svg"
                    headerInteractive: false
                    expanded: false
                    model: DesktopEntries.applications.values
                    .filter(entry => !entry.noDisplay)
                    .sort((a, b) => {
                        const nameA = a.name.toLowerCase();
                        const nameB = b.name.toLowerCase();
                        return nameA.localeCompare(nameB);
                    });
                    shelfItemSize: root.dashShelfItemSize
                }
            }
        }
    }
}
