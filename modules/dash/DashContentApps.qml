import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs
import QuickSearch

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
                    model: FileSystemModel {
                        filter: FileSystemModel.Applications
                        showHidden: false
                        query: searchBar.text
                        minScore: 0.6
                        sort: true
                        sortReverse: false
                        sortProperty: "name"
                    }
                    shelfItemSize: root.dashShelfItemSize
                }
            }
        }
    }
}
