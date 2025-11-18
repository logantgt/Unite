pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property string theme: config.theme
    property string themePath: Quickshell.shellDir + "/themes/" + config.theme
    property string wallpaper: config.wallpaper == "default" ? Config.themePath + "/default" : config.wallpaper
    property bool wallpaperEnabled: config.wallpaperEnabled
    property bool autoAccentColor: config.autoAccentColor
    property color accentColor: config.autoAccentColor ? "#55000000" : config.accentColor
    property color selectionColor: config.selectionColor
    property bool autoSelectionColor: config.autoSelectionColor
    property list<string> taskbarPinnedItems: config.taskbarPinnedItems
    property string taskbarPosition: config.taskbarPosition
    property string desktopName: config.desktopName
    property bool dashMaximized: config.dashMaximized
    property bool dashFullHeight: config.dashFullHeight
    property int dashShelfItemSize: config.dashShelfItemSize
    property list<DesktopEntry> dashRecentItems: config.dashRecentItems

    Binding {
        target: config
        property: "wallpaper"
        value: root.wallpaper
    }

    function dashAddRecentItem(item) {
        // item should be a DesktopEntry
        let reversed = new Array (dashRecentItems.length + 1);

        if(item.id != null) {
            reversed[0] = item;
        } else {
            return;
        }

        for(let i = 0; i < dashRecentItems.length; i++) {
            reversed[i + 1] = dashRecentItems[i];
        }

        config.dashRecentItems = reversed.filter((obj, index, self) =>
        index === self.findIndex((o) => o.id === obj.id)).slice(0, 20);
    }

    FileView {
        path: Quickshell.shellDir + "/config.json"
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: writeAdapter()

        JsonAdapter {
            id: config
            property string theme: "default"
            property string wallpaper: ""
            property bool wallpaperEnabled: true
            property bool autoAccentColor: true
            property color accentColor: "#f0410b0b"
            property bool autoSelectionColor: false
            property color selectionColor: "#e95420"
            property list<string> taskbarPinnedItems: [ "" ]
            property string taskbarPosition: "left"
            property string desktopName: "Ubuntu Desktop"
            property bool dashMaximized: false
            property bool dashFullHeight: false
            property int dashShelfItemSize: 148
            property list<DesktopEntry> dashRecentItems // this is not writing. idk why.
        }
    }
}
