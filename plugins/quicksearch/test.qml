import QtQuick
import QuickSearch

Item {
    width: 400
    height: 300

    FileSystemModel {
        id: testModel
        path: "/home/logan/Documents/GitHub/Unite/plugins/quicksearch"
        recursive: false
        query: "model"

        Component.onCompleted: {
            console.log("FileSystemModel loaded")
            console.log("Path:", path)
            console.log("Query:", query)
            console.log("Entries count:", entries.length)

            for (var i = 0; i < entries.length; i++) {
                console.log("  -", entries[i].name, "(" + entries[i].path + ")")
            }
        }

        onEntriesChanged: {
            console.log("Entries changed! New count:", entries.length)
        }
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: {
            console.log("\nChanging query to 'example'...")
            testModel.query = "example"
        }
    }

    Timer {
        interval: 2000
        running: true
        onTriggered: {
            console.log("\nChanging query to empty (show all)...")
            testModel.query = ""
        }
    }

    Timer {
        interval: 3000
        running: true
        onTriggered: {
            console.log("\nFinal entries count:", testModel.entries.length)
            Qt.quit()
        }
    }
}
