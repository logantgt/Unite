import QtQuick
import Quickshell
import qs

Item {
    id: root
    clip: true

    implicitHeight: expanded ? header.implicitHeight + flowbox.implicitHeight + 10 : (header.implicitHeight / 2) + shelfItemSize
    required property var model
    required property bool expanded
    required property int shelfItemSize
    required property string headerText
    required property bool headerInteractive
    required property string iconSource

    signal headerClicked()

    property var headerSubText
    property var amount: expanded ? model.length : Math.floor(root.width / root.shelfItemSize)

    Component.onCompleted: {
        if(headerInteractive) {
            if(expanded) {
                this.headerSubText = "See fewer results   ▾";
            } else {
                this.headerSubText = "See more results   ▸"
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
            model: root.model

            DashShelfItem {
                size: shelfItemSize
                spacing: 1
            }
        }
    }
}
