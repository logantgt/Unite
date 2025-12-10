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
            placeholderText: "Search files & folders"
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
                    headerText: "Files"
                    iconSource: Config.themePath + "/icons/lens-nav-file.svg"
                    headerInteractive: true
                    expanded: false
                    model: FileSystemModel {
                        filter: FileSystemModel.Files
                        path: "/home/" + Quickshell.env("USER") + "/"
                        showHidden: false
                        query: searchBar.text
                        recursive: true
                        minScore: 0.5
                        maxResults: 100
                        maxDepth: 6
                        sort: true
                        sortReverse: false
                        sortProperty: "fileName"
                    }
                    shelfItemSize: root.dashShelfItemSize
                }

                DashShelf {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    headerText: "Folders"
                    iconSource: Config.themePath + "/icons/lens-nav-folder.svg"
                    headerInteractive: true
                    expanded: false
                    model: FileSystemModel {
                        filter: FileSystemModel.Dirs
                        path: "/home/" + Quickshell.env("USER") + "/"
                        recursive: true
                        query: searchBar.text
                        minScore: 0.5
                        maxDepth: 6
                        maxResults: 100
                        sort: true
                        sortReverse: false
                        sortProperty: "fileName"
                    }//root.createUserFolderEntries().values
                    shelfItemSize: root.dashShelfItemSize
                }
            }
        }
    }
}
