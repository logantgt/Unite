import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.dash
import qs

Item {
    id: root
    property var dashShelfItemSize

    StackLayout {
        id: stack
        currentIndex: 0
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: lens.top
        }

        Loader {
            id: home
            asynchronous: true
            active: true
            sourceComponent: DashContentHome {
                dashShelfItemSize: root.dashShelfItemSize
            }
        }

        Loader {
            id: apps
            asynchronous: true
            active: false
            sourceComponent: DashContentApps {
                dashShelfItemSize: root.dashShelfItemSize
            }
        }

        Loader {
            id: folders
            asynchronous: true
            active: false
            sourceComponent: DashContentFolders {
                dashShelfItemSize: root.dashShelfItemSize
            }
        }

        Loader {
            id: videos
            asynchronous: true
            active: false
            sourceComponent: DashContentVideos {
                dashShelfItemSize: root.dashShelfItemSize
            }
        }

        Loader {
            id: music
            asynchronous: true
            active: false
            sourceComponent: DashContentMusic {
                dashShelfItemSize: root.dashShelfItemSize
            }
        }

        Loader {
            id: photos
            asynchronous: true
            active: false
            sourceComponent: DashContentPhotos {
                dashShelfItemSize: root.dashShelfItemSize
            }
        }
    }

    DashLens {
        id: lens

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        implicitHeight: 40
        color: Qt.darker(Config.accentColor, 1.3)
        bottomRightRadius: Theme.dash_outerCornerRadius
        topLeftRadius: Theme.dash_cornerRadius
        onLensChanged: (page) => {
            stack.currentIndex = page;
            if(page == 0) { home.active = true; }
            if(page == 1) { apps.active = true; }
            if(page == 2) { folders.active = true; }
            if(page == 3) { videos.active = true; }
            if(page == 4) { music.active = true; }
            if(page == 5) { photos.active = true; }
        }
    }
}

