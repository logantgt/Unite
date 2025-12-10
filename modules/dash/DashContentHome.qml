import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs
import QuickSearch

Item {
    id: root
    property var dashShelfItemSize

    function createUserFolderEntries() {
        const folders = [
            { name: "Home", icon: "user-home", path: "./" },
            { name: "Documents", icon: "folder-documents", path: "Documents" },
            { name: "Downloads", icon: "folder-downloads", path: "Downloads" },
            { name: "Music", icon: "folder-music", path: "Music" },
            { name: "Pictures", icon: "folder-pictures", path: "Pictures" },
            { name: "Videos", icon: "folder-videos", path: "Videos" },
            { name: "Desktop", icon: "user-desktop", path: "Desktop" }
        ];

        const entries = folders.map(folder => {

            return {
                name: folder.name,
                icon: folder.icon,
                execString: `xdg-open "${folder.path}"`,
                execute: () => {
                    Quickshell.execDetached({
                        command: ["xdg-open", folder.path]
                    })
                },
                noDisplay: false,
                desktopId: `user-folder-${folder.name.toLowerCase()}`,
                                    genericName: folder.name,
                                    comment: `Open ${folder.name} folder`,
                                    categories: ["Utility", "FileManager"],
                                    isDesktopEntry: true
            };
        });

        return {
            values: entries
        };
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        DashSearch {
            id: searchBar
            Layout.preferredHeight: 54
            Layout.fillWidth: true
            placeholderText: "Search your computer"
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
                    headerInteractive: true
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

                DashShelf {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    headerText: "Places"
                    iconSource: Config.themePath + "/icons/lens-nav-folder.svg"
                    headerInteractive: true
                    expanded: false
                    model: root.createUserFolderEntries().values
                    shelfItemSize: root.dashShelfItemSize
                }

                DashShelf {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    headerText: "Home"
                    iconSource: Config.themePath + "/icons/lens-nav-file.svg"
                    headerInteractive: true
                    expanded: false
                    model: FileSystemModel {
                        filter: FileSystemModel.Files
                        path: "/home/" + Quickshell.env("USER") + "/"
                        showHidden: false
                        query: searchBar.text
                        recursive: false
                        minScore: 0.5
                        maxResults: 60
                        maxDepth: 1
                        sort: true
                        sortReverse: false
                        sortProperty: "fileName"
                    }
                    shelfItemSize: root.dashShelfItemSize
                }
            }
        }
    }
}
