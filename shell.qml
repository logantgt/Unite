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
                active: Config.useBlurMask
                sourceComponent: BlurMask {
                    id: mask
                }
            }
            Menubar {
                id: menubar
            }
            Taskbar {
                id: taskbar
            }
            MenubarShadow {
                id: menubarShadow
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
