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
            placeholderText: "Search music"
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
                    headerText: "Music"
                    iconSource: Config.themePath + "/icons/lens-nav-music.svg"
                    headerInteractive: false
                    expanded: true
                    model: FileSystemModel {
                        filter: FileSystemModel.Files
                        nameFilters: ["*.mp3", "*.flac", "*.m4a", "*.ogg", "*.wav"]
                        path: "/home/" + Quickshell.env("USER") + "/Music"
                        recursive: true
                        query: searchBar.text
                        minScore: 0.5
                        maxDepth: 4
                        maxResults: 1000
                        sort: true
                        sortReverse: false
                        sortProperty: "baseName"
                    }
                    shelfItemSize: root.dashShelfItemSize
                }
            }
        }
    }
}
