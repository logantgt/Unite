import QtQuick
import Quickshell
import qs

Item {
    id: root
    required property var modelData

    QsMenuOpener {
        id: opener
        menu: modelData.menu
    }

    MenubarButton {
        id: btn
        anchors.fill: parent
        menuOpen: menuLoader.active

        Item {
            anchors.centerIn: parent
            width: parent.height - 3
            height: parent.height - 3
            Image {
                anchors.fill: parent
                source: modelData.icon
                sourceSize.width: width
                sourceSize.height: height
            }
        }

        onClicked: (mouse) => {
            if(modelData.hasMenu) {
                if(!menuLoader.active) {
                    GlobalState.sendCloseMenu();
                    menuLoader.loading = true;
                } else {
                    GlobalState.sendCloseMenu();
                    menuLoader.active = false;
                }
            }
        }
    }

    Connections {
        target: GlobalState
        onCloseMenu: {
            menuLoader.active = false;
        }
    }

    // Menu Model
    function getTrayIconMenu(values) {
        let items = [];
        var appliedAction = false;

        for(let i = 0; i < values.length; i++) {
            var item = values[i];
            if(items.count == 0 && item.isSeparator || !item.enabled) { continue; }

            if(!appliedAction && root.modelData.onlyMenu == false) {
                items.push({
                    text: root.modelData.tooltipTitle,
                    hint: "▸",
                    icon: root.modelData.icon,
                    selected: false,
                    checked: false,
                    source: null,
                    interactive: true,
                    action: root.modelData.activate
                });

                if(values[i].isSeparator == false) {
                    items.push({
                        text: "", hint: "", icon: "", selected: false, checked: false, source: "MenuSplitter.qml", interactive: false, action: () => {}
                    });
                }

                appliedAction = true;
            }

            items.push({
                text: item.text,
                hint: "",
                icon: item.icon,
                selected: item.buttonType == QsMenuButtonType.RadioButton && item.checkState > 0 ? true : false,
                checked: item.buttonType == QsMenuButtonType.CheckBox && item.checkState > 0 ? true : false,
                source: item.isSeparator ? "MenuSplitter.qml" : null,
                interactive: item.isSeparator ? false : item.enabled,
                action: item.triggered
            });
        }

        return items;
    }

    LazyLoader {
        id: menuLoader
        loading: false

        MenubarMenu {
            items: getTrayIconMenu(opener.children.values)
            menuWidth: 250
        }
    }
}
