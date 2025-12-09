import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QuickSearch

ApplicationWindow {
    id: root
    visible: true
    width: 800
    height: 600
    title: "QuickSearch Applications Test"

    FileSystemModel {
        id: appModel
        filter: FileSystemModel.Applications
        query: searchField.text
        showHidden: showHiddenCheck.checked
        maxResults: 50

        Component.onCompleted: {
            console.log("Applications model initialized")
        }

        onEntriesChanged: {
            console.log("Found", entries.length, "applications")
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Search controls
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Label {
                text: "Search Applications:"
            }

            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Type to search (e.g., 'firefox', 'editor', 'terminal')..."
            }

            CheckBox {
                id: showHiddenCheck
                text: "Show Hidden (NoDisplay)"
                checked: false
            }

            Label {
                text: `${appModel.entries.length} results`
                font.bold: true
            }
        }

        // Results list
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: listView
                model: appModel
                spacing: 5
                clip: true

                delegate: ItemDelegate {
                    width: listView.width
                    height: 80

                    contentItem: RowLayout {
                        spacing: 15

                        // Application icon placeholder
                        Rectangle {
                            width: 64
                            height: 64
                            radius: 8
                            color: "#3498db"
                            border.color: "#2980b9"
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: modelData.appIcon || "?"
                                font.pixelSize: 12
                                font.family: "monospace"
                                color: "white"
                                wrapMode: Text.Wrap
                                width: parent.width - 10
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        // Application info
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 4

                            Label {
                                text: modelData.appName
                                font.bold: true
                                font.pointSize: 12
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Label {
                                text: modelData.genericName || "(no generic name)"
                                font.italic: true
                                color: "#555"
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                visible: modelData.genericName !== ""
                            }

                            Label {
                                text: modelData.comment || "(no description)"
                                font.pointSize: 9
                                color: "#777"
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                            }

                            RowLayout {
                                spacing: 10

                                Label {
                                    text: "ID: " + modelData.desktopId
                                    font.pointSize: 8
                                    color: "#999"
                                }

                                Label {
                                    text: "Terminal: " + (modelData.runInTerminal ? "Yes" : "No")
                                    font.pointSize: 8
                                    color: "#999"
                                    visible: modelData.runInTerminal
                                }

                                Label {
                                    text: "NoDisplay: " + (modelData.noDisplay ? "Yes" : "No")
                                    font.pointSize: 8
                                    color: "#c33"
                                    visible: modelData.noDisplay
                                }
                            }
                        }

                        // Action count badge
                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: modelData.actions.length > 0 ? "#2ecc71" : "#ecf0f1"
                            visible: modelData.actions.length > 0

                            Label {
                                anchors.centerIn: parent
                                text: modelData.actions.length + "\nactions"
                                font.pointSize: 8
                                horizontalAlignment: Text.AlignHCenter
                                color: modelData.actions.length > 0 ? "white" : "#999"
                            }
                        }
                    }

                    onClicked: {
                        console.log("=== Application Details ===")
                        console.log("Name:", modelData.appName)
                        console.log("Generic Name:", modelData.genericName)
                        console.log("Comment:", modelData.comment)
                        console.log("Icon:", modelData.appIcon)
                        console.log("Exec String:", modelData.execString)
                        console.log("Command:", modelData.command)
                        console.log("Categories:", modelData.categories)
                        console.log("Keywords:", modelData.keywords)
                        console.log("ID:", modelData.desktopId)
                        console.log("NoDisplay:", modelData.noDisplay)
                        console.log("Run in Terminal:", modelData.runInTerminal)
                        console.log("Working Directory:", modelData.workingDirectory)
                        console.log("Startup Class:", modelData.startupClass)
                        console.log("Actions:", modelData.actions.length)
                        for (var i = 0; i < modelData.actions.length; i++) {
                            console.log("  Action", i, ":", modelData.actions[i].name, "->", modelData.actions[i].execString)
                        }
                        console.log("Path:", modelData.path)
                    }
                }

                // Empty state
                Label {
                    anchors.centerIn: parent
                    visible: listView.count === 0
                    text: searchField.text ? "No applications found" : "Type to search applications..."
                    color: "#999"
                    font.pointSize: 14
                }
            }
        }

        // Status bar
        Rectangle {
            Layout.fillWidth: true
            height: 30
            color: "#f0f0f0"
            border.color: "#ccc"
            border.width: 1

            Label {
                anchors.centerIn: parent
                text: "Applications filter uses XDG directories automatically. Try searching for 'firefox', 'chrome', 'code', etc."
                font.pointSize: 9
                color: "#666"
            }
        }
    }
}
