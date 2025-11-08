import QtQuick
import Quickshell
import qs

Item {
    id: root

    implicitHeight: header.implicitHeight + flowbox.implicitHeight + 10
    required property var model
    required property bool expanded
    required property int shelfItemSize
    required property string headerText
    required property bool headerInteractive
    required property string iconSource

    signal headerClicked()

    property var headerSubText
    property var amount: expanded ? model.length : Math.floor(root.width / root.shelfItemSize)
    property var trimmedModel: model.slice(0, amount)
    property var currentModel: expanded ? model : trimmedModel

    Component.onCompleted: {
        if(headerInteractive) {
            if(expanded) {
                this.headerSubText = "See fewer results   ▾";
            } else {
                this.headerSubText = "See %1 more results   ▸".arg(model.length - amount)
            }
        }
    }

    onHeaderClicked: {
        if(this.amount == Math.floor(root.width / root.shelfItemSize)) {
            this.amount = model.length;
            this.expanded = true;
            this.headerSubText = "See fewer results   ▾"
        }
        else {
            this.amount = Math.floor(root.width / root.shelfItemSize)
            this.expanded = false;
            this.headerSubText = "See %1 more results   ▸".arg(model.length - amount)
        }
    }

    Image {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        source: Config.themePath + "/dash/shelf"
    }

    DashShelfHeader {
        id: header
        text: root.headerText
        subText: root.headerSubText
        interactive: headerInteractive
        iconSource: root.iconSource

        onClicked: { root.headerClicked(); }

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    Flow {
        id: flowbox

        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
        }

        Repeater {
            model: root.headerInteractive ? root.currentModel : root.model

            DashShelfItem {
                size: shelfItemSize
                spacing: 1 // Math.floor(((parent.width / shelfItemSize) / Math.floor(parent.width / shelfItemSize)) * 100) / 100 // THIS CAUSES A POLISH LOOP!!!
            }
        }
    }
}
