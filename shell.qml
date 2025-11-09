import QtQuick
import Quickshell
import qs
import qs.modules
import qs.modules.taskbar
import qs.modules.menubar
import qs.modules.wallpaper

ShellRoot {
    Variants {
        model: Quickshell.screens

        Item {
            id: root
            required property var modelData
            Loader {
                id: wallpaper
                active: Config.wallpaperEnabled
                sourceComponent: Item {
                    OverviewWallpaper { modelData: root.modelData }
                    Wallpaper { modelData: root.modelData }
                }
            }
            Loader {
                id: blurMask
                active: true
                sourceComponent: BlurMask { }
            }
            Loader {
                id: menubar
                active: blurMask.sourceComponent.backingWindowVisible
                sourceComponent: Menubar { }
            }
            Loader {
                id: taskbar
                active: menubar.sourceComponent.backingWindowVisible
                sourceComponent: Taskbar { }
            }
            Loader {
                id: menubarShadow
                active: taskbar.sourceComponent.backingWindowVisible
                sourceComponent: MenubarShadow { }
            }
        }
    }
}
