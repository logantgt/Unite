import Quickshell
import QtQuick
import qs

PopupWindow {
    id: popupBase

    // Required Properties
    required property var targetWidget
    required property var padding
    required property var extendFrom

    // Properties
    property real opacity: 1
    default property alias data: borderImage.data

    visible: true
    anchor.item: targetWidget

    anchor.rect.x: extendFrom == Edges.Left ? targetWidget.width + padding : -(this.implicitWidth + padding)
    anchor.rect.y: (targetWidget.height / 2) - (popupBase.height / 2)
    color: "transparent"

    BorderImage {
        id: borderImage
        anchors {
            fill: parent
        }

        border { left: 8; top: 8; right: 8; bottom: 8 }
        horizontalTileMode: BorderImage.Stretch
        verticalTileMode: BorderImage.Stretch
        source: Config.themePath + "/popupFrame.svg"
        opacity: popupBase.opacity
    }
}
