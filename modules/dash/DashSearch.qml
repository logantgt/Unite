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
        anchors.fill: parent
        anchors.topMargin: 12
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        TextField {
            id: searchbox
            anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
                verticalCenter: parent.verticalCenter
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
        implicitWidth: parent.width * (1 / 1.61803398875)
    }
}
