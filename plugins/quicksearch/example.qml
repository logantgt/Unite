import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QuickSearch

ApplicationWindow {
    id: root
    visible: true
    width: 800
    height: 600
    title: "QuickSearch Example"

    FileSystemModel {
        id: searchModel
        path: "/home"  // Change this to your desired search path
        recursive: true
        showHidden: false
        query: searchField.text
        minScore: 0.3  // Minimum fuzzy match score (0.0 to 1.0)

        // Performance optimizations
        maxDepth: 3     // Limit recursion depth (-1 for unlimited)
        maxResults: 100 // Limit number of results (-1 for unlimited)

        // Optional: Filter by file type
        // filter: FileSystemModel.Files

        // Optional: Filter by file extensions
        // nameFilters: ["*.txt", "*.md", "*.qml"]
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Search input
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Label {
                text: "Search:"
            }

            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Type to search files..."

                // The model updates automatically when you type!
            }

            Label {
                text: `${searchModel.entries.length} results`
            }
        }

        // Search options
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            CheckBox {
                id: recursiveCheck
                text: "Recursive"
                checked: searchModel.recursive
                onCheckedChanged: searchModel.recursive = checked
            }

            CheckBox {
                id: hiddenCheck
                text: "Show Hidden"
                checked: searchModel.showHidden
                onCheckedChanged: searchModel.showHidden = checked
            }

            Label {
                text: "Min Score:"
            }

            SpinBox {
                from: 0
                to: 100
                value: searchModel.minScore * 100
                onValueChanged: searchModel.minScore = value / 100.0
            }
        }

        // Performance options
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Label {
                text: "Max Depth:"
                enabled: recursiveCheck.checked
            }

            SpinBox {
                id: maxDepthSpinBox
                from: -1
                to: 20
                value: searchModel.maxDepth
                enabled: recursiveCheck.checked
                onValueChanged: searchModel.maxDepth = value

                textFromValue: function(value) {
                    return value < 0 ? "Unlimited" : value.toString()
                }
            }

            Label {
                text: "Max Results:"
            }

            SpinBox {
                id: maxResultsSpinBox
                from: -1
                to: 10000
                stepSize: 50
                value: searchModel.maxResults
                onValueChanged: searchModel.maxResults = value

                textFromValue: function(value) {
                    return value < 0 ? "Unlimited" : value.toString()
                }
            }
        }

        // Results list
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: listView
                model: searchModel
                spacing: 5

                delegate: ItemDelegate {
                    width: listView.width
                    height: 40

                    contentItem: RowLayout {
                        spacing: 10

                        // File icon (simple indicator)
                        Rectangle {
                            width: 24
                            height: 24
                            radius: 4
                            color: modelData.isDir ? "#4A90E2" : "#7ED321"

                            Text {
                                anchors.centerIn: parent
                                text: modelData.isDir ? "D" : "F"
                                color: "white"
                                font.bold: true
                            }
                        }

                        // File info
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Label {
                                text: modelData.name
                                font.bold: true
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Label {
                                text: modelData.path
                                font.pointSize: 9
                                color: "#888"
                                Layout.fillWidth: true
                                elide: Text.ElideMiddle
                            }
                        }

                        // File size
                        Label {
                            text: modelData.isDir ? "" : formatSize(modelData.size)
                            color: "#666"
                            font.pointSize: 9
                        }
                    }

                    onClicked: {
                        console.log("Clicked:", modelData.path)
                    }
                }

                // Empty state
                Label {
                    anchors.centerIn: parent
                    visible: listView.count === 0
                    text: searchField.text ? "No results found" : "Type to search..."
                    color: "#999"
                    font.pointSize: 14
                }
            }
        }
    }

    // Helper function to format file sizes
    function formatSize(bytes) {
        if (bytes < 1024) return bytes + " B"
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB"
        if (bytes < 1024 * 1024 * 1024) return (bytes / (1024 * 1024)).toFixed(1) + " MB"
        return (bytes / (1024 * 1024 * 1024)).toFixed(1) + " GB"
    }
}
