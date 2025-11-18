import QtQuick
import QtQuick.Controls
import Quickshell
import qs

Button {
    id: root
    required property bool menuOpen
    flat: false

    background: BorderImage {
        id: outline
        source: Config.themePath + "/menubar_icon_click.svg"
        border { left: 7; top: 7; right: 7; bottom: 7 }
        width: parent.width
        height: parent.height
        opacity: parent.pressed || root.menuOpen ? 1 : 0
    }
}
