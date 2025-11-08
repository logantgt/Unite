import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs

Item {
    id: root
    property var dashShelfItemSize

    Process {
        id: videoSearchProcess
        running: true
        property string searchQuery: searchBar.text

        command: {
            const videoExtensions = "mp3|flac|wav|ogg|m4a|aac|wma|opus|ape|alac|aiff|aif|oga|mka|dsd|dsf|wv";
            return [
                "sh", "-c",
                searchQuery
                ? `find ~/Music -type f -regextype posix-extended -iregex '.*\\.(${videoExtensions})$' | fzf --filter="${searchQuery}"`
                : `find ~/Music -type f -regextype posix-extended -iregex '.*\\.(${videoExtensions})$' | sort`
            ];
        }

        stdout: StdioCollector {
            onStreamFinished: {
                shelf.model = parseVideoResults(this.text).slice(0, 60);
            }
        }
    }

    function parseVideoResults(data) {
        const output = data.trim();
        if (!output) return [];

        return output.split('\n').map(filePath => {
            const fileName = filePath.split('/').pop();
            const nameWithoutExt = fileName.replace(/\.[^/.]+$/, "");

            return {
                name: nameWithoutExt,
                icon: filePath.split(fileName)[0] + '/folder',
                execString: `xdg-open "${filePath}"`,
                execute: () => {
                    Quickshell.execDetached({
                        command: ["xdg-open", filePath]
                    });
                },
                noDisplay: false,
                desktopId: `video-${fileName}`,
                genericName: "Video File",
                comment: filePath,
                categories: ["Video", "AudioVideo"]
            };
        });
    }

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
                    expanded: false
                    model: 0
                    shelfItemSize: root.dashShelfItemSize
                }
            }
        }
    }
}
