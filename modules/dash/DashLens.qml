import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.modules

Rectangle {
    id: root

    signal lensChanged(page: int)

    function clearButtonsActiveState() {
        home.active = false;
        app.active = false;
        file.active = false;
        video.active = false;
        music.active = false;
        photo.active = false;
    }

    RowLayout {
        anchors.fill: parent

        Spacer {
            size: 1
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        DashLensButton {
            id: home
            iconSource: Config.themePath + "/icons/lens-nav-home.svg"
            active: true
            Layout.preferredWidth: 60
            Layout.fillWidth: false
            Layout.fillHeight: true
            onClicked: {
                root.clearButtonsActiveState();
                this.active = true;
                lensChanged(0);
            }
        }

        DashLensButton {
            id: app
            iconSource: Config.themePath + "/icons/lens-nav-app.svg"
            active: false
            Layout.preferredWidth: 60
            Layout.fillWidth: false
            Layout.fillHeight: true
            onClicked: {
                root.clearButtonsActiveState();
                this.active = true;
                lensChanged(1);
            }
        }

        DashLensButton {
            id: file
            iconSource: Config.themePath + "/icons/lens-nav-file.svg"
            active: false
            Layout.preferredWidth: 60
            Layout.fillWidth: false
            Layout.fillHeight: true
            onClicked: {
                root.clearButtonsActiveState();
                this.active = true;
                lensChanged(2);
            }
        }

        DashLensButton {
            id: video
            iconSource: Config.themePath + "/icons/lens-nav-video.svg"
            active: false
            Layout.preferredWidth: 60
            Layout.fillWidth: false
            Layout.fillHeight: true
            onClicked: {
                root.clearButtonsActiveState();
                this.active = true;
                lensChanged(3);
            }
        }

        DashLensButton {
            id: music
            iconSource: Config.themePath + "/icons/lens-nav-music.svg"
            active: false
            Layout.preferredWidth: 60
            Layout.fillWidth: false
            Layout.fillHeight: true
            onClicked: {
                root.clearButtonsActiveState();
                this.active = true;
                lensChanged(4);
            }
        }

        DashLensButton {
            id: photo
            iconSource: Config.themePath + "/icons/lens-nav-photo.svg"
            active: false
            Layout.preferredWidth: 60
            Layout.fillWidth: false
            Layout.fillHeight: true
            onClicked: {
                root.clearButtonsActiveState();
                this.active = true;
                lensChanged(5);
            }
        }

        Spacer {
            size: 1
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
