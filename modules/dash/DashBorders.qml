import QtQuick

Item {
    anchors.fill: parent

    Image {
        id: dash_top_right_corner
        anchors {
            top: parent.top
            left: dashBase.right
            topMargin: -10
            leftMargin: -10
        }

        source: Config.themePath + "/dash/dash_top_right_corner"
        smooth: false
    }

    Image {
        id: dash_right_border_tile
        anchors {
            top: dash_top_right_corner.bottom
            left: dashBase.right
            bottom: dashBase.botttom
            leftMargin: -10
        }

        height: dashBase.height - dash_top_right_corner.height

        source: Config.themePath + "/dash/dash_right_border_tile"
        fillMode: Image.TileVertically
        smooth: false
    }

    Image {
        anchors {
            top: parent.top
            left: dash_top_right_corner.right
            right: parent.right
            topMargin: -10
        }
        source: Config.themePath + "/dash/dash_top_tile"
        fillMode: Image.TileHorizontally
        smooth: false
    }

    Image {
        id: dash_bottom_left_corner
        anchors {
            top: dashBase.bottom
            left: parent.left
            topMargin: -10
            leftMargin: -10
        }

        source: Config.themePath + "/dash/dash_bottom_left_corner"
        smooth: false
    }

    Image {
        id: dash_bottom_border_tile
        anchors {
            top: dashBase.bottom
            left: dash_bottom_left_corner.right
            bottom: dash_bottom_left_corner.botttom
            topMargin: -10
        }

        width: dashBase.width - dash_bottom_left_corner.width

        source: Config.themePath + "/dash/dash_bottom_border_tile"
        fillMode: Image.TileHorizontally
        smooth: false
    }

    Image {
        anchors {
            top: dash_right_border_tile.bottom
            left: dash_bottom_border_tile.right
        }

        source: Config.themePath + "/dash/dash_bottom_right_corner"
        smooth: false
    }

    Image {
        anchors {
            top: dash_bottom_left_corner.bottom
            left: parent.left
            bottom: parent.bottom
            leftMargin: -10
        }
        source: Config.themePath + "/dash/dash_left_tile"
        fillMode: Image.TileVertically
        smooth: false
    }
}
