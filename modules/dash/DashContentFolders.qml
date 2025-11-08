import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs

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
                                    categories: ["Utility", "FileManager"]
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
                    headerText: "Folders"
                    iconSource: Config.themePath + "/icons/lens-nav-file.svg"
                    headerInteractive: false
                    expanded: false
                    model: root.createUserFolderEntries().values
                    shelfItemSize: root.dashShelfItemSize
                }
            }
        }
    }
}
