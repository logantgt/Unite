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

    Variants {
        model: Quickshell.screens
        OverviewWallpaper {}
    }

    Variants {
        model: Quickshell.screens
        Wallpaper {}
    }
}
