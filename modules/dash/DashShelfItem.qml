import QtQuick
import Quickshell
import qs

Item {
    id: root
    required property int size
    required property var modelData
    required property var spacing

    implicitWidth: size * spacing
    implicitHeight: size - 6

    MouseArea {
        hoverEnabled: true

        anchors.fill: parent

        onEntered: {
            selectionBox.opacity = 1;
        }

        onExited: {
            selectionBox.opacity = 0;
        }

        onClicked: {
            if(modelData.isDesktopEntry) {
                modelData.execute();
            } else {
                Quickshell.execDetached({
                    command: ["xdg-open", modelData.path],
                    workingDirectory: modelData.parentDir
                });
            }
            Config.dashAddRecentItem(modelData);
            GlobalState.sendCloseDash();
        }
    }

    Rectangle {
        id: selectionBox
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        implicitWidth: size - 50
        implicitHeight: size - 50
        color: "#40ffffff"
        radius: 3
        opacity: 0

        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }
    }

    function mimeToIcon(mime) {
        if (!mime || typeof mime !== "string") return "unknown";

        const map = {
            // Text
            "text/plain": "text-x-generic",
            "text/html": "text-html",
            "text/css": "text-x-script",
            "text/javascript": "text-x-script",

            // Images
            "image/jpeg": "image-x-generic",
            "image/png": "image-x-generic",
            "image/gif": "image-x-generic",
            "image/svg+xml": "image-svg+xml",

            // Audio
            "audio/mpeg": "audio-x-generic",
            "audio/wav": "audio-x-generic",
            "audio/ogg": "audio-x-generic",

            // Video
            "video/mp4": "video-x-generic",
            "video/x-msvideo": "video-x-generic",
            "video/quicktime": "video-x-generic",

            // PDFs & docs
            "application/pdf": "application-pdf",
            "application/msword": "application-vnd.ms-word",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document": "application-vnd.openxmlformats-officedocument.wordprocessingml.document",
            "application/vnd.ms-excel": "application-vnd.ms-excel",
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": "application-vnd.openxmlformats-officedocument.spreadsheetml.sheet",

            // Archives
            "application/zip": "package-x-generic",
            "application/x-tar": "package-x-generic",
            "application/x-gzip": "package-x-generic",

            // JSON / XML
            "application/json": "text-x-script",
            "application/xml": "text-xml",
        };

        // Direct match
        if (map[mime]) return map[mime];

        const [type] = mime.split("/");

        // Fallbacks by top-level type
        const fallback = {
            text: "text-x-generic",
            image: "image-x-generic",
            audio: "audio-x-generic",
            video: "video-x-generic",
            application: "application-x-executable",
        };

        return fallback[type] || "unknown";
    }

    Image {
        id: icon
        anchors.fill: selectionBox
        anchors.margins: 12
        source: {
            if(modelData.isImage) {
                return modelData.imageThumbnail;
            }

            if(modelData.isVideo) {
                return "file://" + modelData.videoThumbnail;
            }

            if(modelData.isMusic) {
                return "file://" + modelData.musicThumbnail;
            }

            if(modelData.isDesktopEntry) {
                return Quickshell.iconPath(modelData.icon);
            }

            if(modelData.isDir) {
                return Quickshell.iconPath("folder");
            }

            return Quickshell.iconPath(mimeToIcon(modelData.mimeType))
        }
        fillMode: Image.PreserveAspectFit
        cache: false
        asynchronous: true
        sourceSize.width: selectionBox.width
        sourceSize.height: selectionBox.height
    }

    Text {
        anchors {
            top: selectionBox.bottom
            left: selectionBox.left
            right: selectionBox.right
        }
        text: {
            if(modelData.isDesktopEntry) {
                return modelData.name;
            } else if (modelData.isMusic) {
                return modelData.baseName;
            } else {
                return modelData.fileName;
            }
        }
        color: "white"
        font.family: "Ubuntu"
        maximumLineCount: 2
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        elide: Text.ElideRight
    }
}
