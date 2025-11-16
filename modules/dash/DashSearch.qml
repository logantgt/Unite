import QtQuick
import QtQuick.Controls
import Quickshell
import qs

Item {
    id: root
    signal searchTextChanged()
    property var text: searchbox.text
    property var placeholderText

    Rectangle {
        id: hoverHighlight
        color: "white"
        radius: 3
        anchors {
            top: parent.top
            left: searchBase.right
            right: parent.right
            bottom: parent.bottom
            leftMargin: 6
            rightMargin: 6
            topMargin: 18
            bottomMargin: 10
        }
        opacity: 0
    }

    Text {
        id: headerText
        anchors.fill: hoverHighlight
        leftPadding: 8
        text: "Filter results   ▸  "
        color: "white"
        font.family: "Ubuntu"
        font.pointSize: 12
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            hoverHighlight.opacity = 0.25
        }

        onExited: {
            hoverHighlight.opacity = 0
        }

        onClicked: {
            root.clicked();
        }
    }

    Rectangle {
        id: searchBase
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
            topMargin: 12
            leftMargin: 10
            rightMargin: 10
        }

        Image {
            id: searchIcon
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            source: Config.themePath + "/dash/search.svg"
            smooth: true
            width: 40
            height: width

        }

        TextField {
            id: searchbox
            anchors {
                top: parent.top
                left: searchIcon.right
                bottom: parent.bottom
                leftMargin: -10
            }

            background: Item {}

            placeholderText: root.placeholderText
            placeholderTextColor: Qt.tint("white", Qt.rgba(Config.accentColor.r, Config.accentColor.g, Config.accentColor.b, 0.55))

            font.family: "Ubuntu"
            font.pixelSize: 20
            font.italic: true

            onTextChanged: { root.searchTextChanged() }
        }

        color: Qt.darker(Config.accentColor, 1.4)
        radius: 5
        border.color: "#B0ffffff"
        border.width: 1
        implicitWidth: parent.width * (1 / 1.5)
    }
}
