import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
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
            placeholderText: "Search photos"
            onSearchTextChanged: { videoSearchProcess.running = true; }
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
                    id: shelf
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    headerText: "Photos"
                    iconSource: Config.themePath + "/icons/lens-nav-photo.svg"
                    headerInteractive: false
                    expanded: true
                    model: FileSystemModel {
                        filter: FileSystemModel.Files
                        path: "/home/logan/Pictures"
                        recursive: true
                        query: searchBar.text
                        minScore: 0.5
                        maxDepth: 4
                        maxResults: 600
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
