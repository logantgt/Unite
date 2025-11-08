pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property int menubar_height: menubarConfig.height
    property int menubar_shadowHeight: menubarConfig.shadowHeight
    property real menubar_opacity: menubarConfig.opacity
    property color menubar_fontColor: menubarConfig.fontColor

    FileView {
        path: Config.themePath + "/menubar.json"
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: writeAdapter()

        JsonAdapter {
            id: menubarConfig
            property int height: 26
            property int shadowHeight: 8
            property real opacity: 1
            property color fontColor: "#dfdfdf"
        }
    }

    property int taskbar_width: taskbarConfig.width
    property real taskbar_opacity: taskbarConfig.opacity
    property color taskbar_borderColor: taskbarConfig.borderColor
    property int taskbar_borderWidth: taskbarConfig.borderWidth
    property int taskbar_taskItemSpacing: taskbarConfig.taskItemSpacing

    FileView {
        path: Config.themePath + "/taskbar.json"
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: writeAdapter()

        JsonAdapter {
            id: taskbarConfig
            property int width: 65
            property real opacity: 1
            property color borderColor: "#00000000"
            property int borderWidth: 1
            property int taskItemSpacing: 0
        }
    }

    property int tasklistitem_itemMargins: tasklistitemConfig.itemMargins
    property int tasklistitem_iconMargins: tasklistitemConfig.iconMargins
    property color tasklistitem_tooltipTextColor: tasklistitemConfig.tooltipTextColor
    property bool tasklistitem_hotTrack: tasklistitemConfig.hotTrack

    FileView {
        path: Config.themePath + "/tasklistitem.json"
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: writeAdapter()

        JsonAdapter {
            id: tasklistitemConfig
            property int itemMargins: 2
            property int iconMargins: 8
            property color tooltipTextColor: "white"
            property bool hotTrack: true
        }
    }

    property int dash_animationDuration: dashConfig.animationDuration

    FileView {
        path: Config.themePath + "/dash.json"
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: writeAdapter()

        JsonAdapter {
            id: dashConfig
            property int animationDuration: 100
        }
    }
}
