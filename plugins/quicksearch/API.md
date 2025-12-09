# QuickSearch API Reference

Comprehensive API documentation for the QuickSearch QML plugin - a filesystem search library with fuzzy matching capabilities.

## Import Statement

```qml
import QuickSearch
```

## Quick Start

```qml
import QtQuick
import QuickSearch

ListView {
    model: FileSystemModel {
        path: "/home/user/Documents"
        recursive: true
        query: "myfile"
    }

    delegate: Text {
        text: modelData.name + " - " + modelData.path
    }
}
```

---

## Class Overview

| Class | Type | Purpose |
|-------|------|---------|
| `FileSystemModel` | QAbstractListModel | Primary API - filesystem browser with fuzzy search |
| `FileSystemEntry` | QObject (uncreatable) | File/directory entry with metadata and desktop app info |
| `DesktopAction` | QObject (uncreatable) | Desktop action from .desktop file |
| `QuickSearch` | QObject | Simple query/paths holder |
| `CachingImageManager` | QObject | Image caching utility for performance |

---

# FileSystemModel

The primary API for searching and listing files with integrated fuzzy search capabilities. Extends `QAbstractListModel` for seamless ListView integration.

## Filter Enum

Controls what types of filesystem entries to include in results.

| Enum Value | QML Access | Description |
|------------|-----------|-------------|
| `NoFilter` | `FileSystemModel.NoFilter` | Show all files and directories (default) |
| `Files` | `FileSystemModel.Files` | Only show files |
| `Dirs` | `FileSystemModel.Dirs` | Only show directories |
| `Images` | `FileSystemModel.Images` | Only show readable image files |
| `Applications` | `FileSystemModel.Applications` | Show installed applications from XDG directories |

## Properties

### Path and Search

| Property | Type | Access | Default | Description |
|----------|------|--------|---------|-------------|
| `path` | `string` | Read/Write | `""` | Root directory to search in |
| `recursive` | `bool` | Read/Write | `false` | Search subdirectories recursively |
| `query` | `string` | Read/Write | `""` | Fuzzy search query (empty shows all files) |

### Filtering

| Property | Type | Access | Default | Description |
|----------|------|--------|---------|-------------|
| `filter` | `Filter` | Read/Write | `NoFilter` | Filter by entry type (see Filter enum) |
| `nameFilters` | `list<string>` | Read/Write | `[]` | File extension filters (e.g., `["*.txt", "*.md"]`) |
| `showHidden` | `bool` | Read/Write | `false` | Include hidden files in results |

### Fuzzy Search Scoring

| Property | Type | Access | Default | Description |
|----------|------|--------|---------|-------------|
| `minScore` | `double` | Read/Write | `0.3` | Minimum fuzzy match score (0.0 to 1.0) |

**Score Weighting**:
- Character matching: 40%
- Prefix matching: 30%
- Consecutive characters: 20%
- Match position: 10%

### Performance Optimization

| Property | Type | Access | Default | Description |
|----------|------|--------|---------|-------------|
| `maxDepth` | `int` | Read/Write | `-1` | Maximum recursion depth (`-1` for unlimited) |
| `maxResults` | `int` | Read/Write | `-1` | Maximum number of results (`-1` for unlimited) |

**Performance Tips**:
- Set `maxDepth: 3` to limit recursive search to 3 directory levels
- Set `maxResults: 100` to stop after finding 100 matches
- Use these together for significant performance gains on large directory trees

### Behavior

| Property | Type | Access | Default | Description |
|----------|------|--------|---------|-------------|
| `watchChanges` | `bool` | Read/Write | `true` | Watch filesystem for changes and update automatically |
| `sortReverse` | `bool` | Read/Write | `false` | Reverse sort order |

### Output

| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `entries` | `list<FileSystemEntry>` | Read-only | List of all matching entries |

## Signals

All properties emit change signals:

```qml
pathChanged()
recursiveChanged()
watchChangesChanged()
showHiddenChanged()
sortReverseChanged()
filterChanged()
nameFiltersChanged()
queryChanged()
minScoreChanged()
maxDepthChanged()
maxResultsChanged()
entriesChanged()
```

## Usage Examples

### Basic File Listing

```qml
FileSystemModel {
    path: "/home/user/Documents"
    recursive: false
    // Shows all files in directory (no search query)
}
```

### Fuzzy Search

```qml
FileSystemModel {
    path: "/home/user"
    recursive: true
    query: "config"           // Fuzzy match against filenames
    minScore: 0.3             // Only show decent matches
}
```

### Filter by File Type

```qml
FileSystemModel {
    path: "/home/user/Projects"
    recursive: true
    filter: FileSystemModel.Files  // Only files, no directories
    nameFilters: ["*.qml", "*.js"] // Only QML and JS files
}
```

### Search for Directories Only

```qml
FileSystemModel {
    path: "/home/user"
    recursive: true
    filter: FileSystemModel.Dirs  // Only directories
    query: "project"
}
```

### Search for Images

```qml
FileSystemModel {
    path: "/home/user/Pictures"
    recursive: true
    filter: FileSystemModel.Images  // Only readable images
    query: "vacation"
}
```

### Search Installed Applications

```qml
FileSystemModel {
    filter: FileSystemModel.Applications
    query: "firefox"              // Fuzzy search across app name, description, keywords
    showHidden: false             // Hide NoDisplay=true apps
    maxResults: 50                // Limit results

    // NOTE: path property is ignored for Applications filter
    // Automatically searches XDG_DATA_HOME and XDG_DATA_DIRS
}
```

### Performance Optimization

```qml
FileSystemModel {
    path: "/home/user"
    recursive: true
    query: "readme"

    // Performance settings for large directories
    maxDepth: 3        // Only search 3 levels deep
    maxResults: 50     // Stop after 50 matches
}
```

### ListView Integration

```qml
ListView {
    model: FileSystemModel {
        path: "/home/user/Documents"
        recursive: true
        query: searchField.text
    }

    delegate: ItemDelegate {
        width: ListView.view.width
        text: modelData.name

        onClicked: console.log("Selected:", modelData.path)
    }
}
```

---

# FileSystemEntry

Represents a single file or directory entry. **Cannot be created directly in QML** - instances are only obtained from `FileSystemModel`.

## Properties

All properties are **read-only** and computed from the filesystem.

### Basic File Properties

| Property | Type | Description |
|----------|------|-------------|
| `path` | `string` | Absolute file path |
| `relativePath` | `string` | Path relative to search root |
| `name` | `string` | File name with extension |
| `baseName` | `string` | File name without extension |
| `parentDir` | `string` | Parent directory absolute path |
| `suffix` | `string` | File extension(s) |
| `size` | `int` | File size in bytes |
| `isDir` | `bool` | `true` if entry is a directory |
| `isImage` | `bool` | `true` if entry is a readable image |
| `mimeType` | `string` | MIME type of the file |

### Desktop Entry Properties

Available when `filter: FileSystemModel.Applications` and `isDesktopEntry` is `true`. Compatible with Quickshell DesktopEntry API.

| Property | Type | Description |
|----------|------|-------------|
| `isDesktopEntry` | `bool` | `true` if this entry is a parsed .desktop file |
| `appName` | `string` | Application name (localized) |
| `genericName` | `string` | Generic application name (e.g., "Web Browser") |
| `comment` | `string` | Application description/comment |
| `appIcon` | `string` | Icon name or path |
| `command` | `list<string>` | Parsed command array (field codes removed) |
| `execString` | `string` | Raw Exec string from .desktop file |
| `categories` | `list<string>` | Application categories |
| `keywords` | `list<string>` | Search keywords (localized) |
| `actions` | `list<DesktopAction>` | Desktop actions for this application |
| `desktopId` | `string` | Desktop file ID (filename) |
| `noDisplay` | `bool` | `true` if NoDisplay=true in .desktop file |
| `runInTerminal` | `bool` | `true` if Terminal=true in .desktop file |
| `workingDirectory` | `string` | Working directory (Path key) |
| `startupClass` | `string` | StartupWMClass value |

## Signals

```qml
relativePathChanged()
```

## Usage Examples

### Access in ListView Delegate

```qml
ListView {
    model: FileSystemModel { /* ... */ }

    delegate: Column {
        Text { text: "Name: " + modelData.name }
        Text { text: "Path: " + modelData.path }
        Text { text: "Size: " + modelData.size + " bytes" }
        Text { text: "Type: " + (modelData.isDir ? "Directory" : "File") }
    }
}
```

### Access via entries Property

```qml
FileSystemModel {
    id: searchModel
    path: "/home/user"
    query: "config"
}

Repeater {
    model: searchModel.entries
    delegate: Text {
        text: modelData.name
    }
}

Text {
    text: "Found " + searchModel.entries.length + " results"
}
```

### File Type Checking

```qml
delegate: Item {
    Rectangle {
        color: modelData.isDir ? "blue" : "green"
        // Different colors for directories vs files
    }

    Text {
        text: modelData.name
    }

    Image {
        visible: modelData.isImage
        source: modelData.path
    }
}
```

---

# DesktopAction

Represents a desktop action from a .desktop file (e.g., "New Window", "New Private Window"). **Cannot be created directly in QML** - instances are only obtained from `FileSystemEntry.actions`.

Compatible with Quickshell DesktopAction API.

## Properties

All properties are **read-only**.

| Property | Type | Description |
|----------|------|-------------|
| `id` | `string` | Action identifier |
| `name` | `string` | Action name (localized) |
| `execString` | `string` | Raw Exec string for this action |
| `icon` | `string` | Icon name or path for this action |
| `command` | `list<string>` | Parsed command array (field codes removed) |

## Usage Example

```qml
ListView {
    model: FileSystemModel {
        filter: FileSystemModel.Applications
        query: "firefox"
    }

    delegate: Column {
        Text { text: modelData.appName }

        // Show available actions
        Repeater {
            model: modelData.actions
            delegate: Button {
                text: modelData.name
                onClicked: {
                    console.log("Execute:", modelData.command)
                    // Use modelData.command to launch the action
                }
            }
        }
    }
}
```

---

# QuickSearch

Simple container for search query and paths. Less commonly used than `FileSystemModel`.

## Properties

| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `query` | `string` | Read/Write | Search query string |
| `paths` | `list<string>` | Read/Write | List of paths to search |

## Signals

```qml
queryChanged()
pathsChanged()
```

## Usage Example

```qml
QuickSearch {
    id: search
    query: "myfile"
    paths: ["/home/user/Documents", "/home/user/Projects"]
}

Text {
    text: "Searching for: " + search.query
}
```

---

# CachingImageManager

Utility for caching images based on item size. Useful for performance when displaying many images.

## Properties

| Property | Type | Access | Required | Description |
|----------|------|--------|----------|-------------|
| `item` | `QQuickItem` | Read/Write | Yes | Item to monitor for size changes |
| `cacheDir` | `url` | Read/Write | Yes | Directory for storing cached images |
| `path` | `string` | Read/Write | No | Source image path |
| `cachePath` | `url` | Read-only | No | Computed cache file path |

## Methods

| Method | Parameters | Description |
|--------|-----------|-------------|
| `updateSource()` | None | Reload/update image from source |
| `updateSource(path)` | `string path` | Update source with new image path |

## Signals

```qml
itemChanged()
cacheDirChanged()
pathChanged()
cachePathChanged()
usingCacheChanged()
```

## Usage Example

```qml
import QtQuick
import QuickSearch

Image {
    id: thumbnail

    CachingImageManager {
        item: thumbnail
        cacheDir: "file:///home/user/.cache/thumbnails"
        path: modelData.path
    }

    source: cachePath
}
```

---

# Complete Examples

## Full-Featured Search Application

```qml
import QtQuick
import QtQuick.Controls
import QuickSearch

ApplicationWindow {
    visible: true
    width: 800
    height: 600

    Column {
        anchors.fill: parent

        // Search controls
        Row {
            spacing: 10

            TextField {
                id: searchField
                placeholderText: "Search..."
                width: 300
            }

            TextField {
                id: pathField
                text: "/home/user"
                width: 200
            }

            CheckBox {
                id: recursiveBox
                text: "Recursive"
                checked: true
            }
        }

        // Options
        Row {
            spacing: 10

            ComboBox {
                id: filterBox
                model: ["All", "Files", "Directories", "Images"]
            }

            SpinBox {
                id: depthBox
                from: -1
                to: 10
                value: -1
                textFromValue: (v) => v < 0 ? "Unlimited" : v.toString()
            }
        }

        // Results
        ListView {
            width: parent.width
            height: parent.height - 100

            model: FileSystemModel {
                path: pathField.text
                recursive: recursiveBox.checked
                query: searchField.text
                maxDepth: depthBox.value
                maxResults: 200

                filter: {
                    switch(filterBox.currentIndex) {
                        case 1: return FileSystemModel.Files
                        case 2: return FileSystemModel.Dirs
                        case 3: return FileSystemModel.Images
                        default: return FileSystemModel.NoFilter
                    }
                }
            }

            delegate: ItemDelegate {
                width: ListView.view.width
                text: modelData.name + " - " + modelData.path

                Rectangle {
                    width: 16
                    height: 16
                    color: modelData.isDir ? "blue" : "green"
                }
            }
        }
    }
}
```

## Application Launcher

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QuickSearch

ApplicationWindow {
    visible: true
    width: 600
    height: 400

    Column {
        anchors.fill: parent
        spacing: 10

        TextField {
            id: searchField
            width: parent.width
            placeholderText: "Search applications..."
        }

        ListView {
            width: parent.width
            height: parent.height - searchField.height - 10

            model: FileSystemModel {
                filter: FileSystemModel.Applications
                query: searchField.text
                showHidden: false  // Hide NoDisplay apps
                maxResults: 50
            }

            delegate: ItemDelegate {
                width: ListView.view.width
                height: 80

                contentItem: RowLayout {
                    spacing: 15

                    // Icon placeholder
                    Rectangle {
                        width: 48
                        height: 48
                        radius: 8
                        color: "#3498db"

                        Text {
                            anchors.centerIn: parent
                            text: modelData.appIcon
                            color: "white"
                        }
                    }

                    // App info
                    ColumnLayout {
                        Layout.fillWidth: true

                        Text {
                            text: modelData.appName
                            font.bold: true
                            font.pointSize: 12
                        }

                        Text {
                            text: modelData.comment
                            font.pointSize: 9
                            color: "#666"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        // Show actions if available
                        Row {
                            spacing: 5
                            visible: modelData.actions.length > 0

                            Repeater {
                                model: modelData.actions
                                delegate: Button {
                                    text: modelData.name
                                    height: 20
                                    font.pointSize: 8
                                }
                            }
                        }
                    }
                }

                onClicked: {
                    console.log("Launch:", modelData.command)
                    // Execute: modelData.command
                }
            }
        }
    }
}
```

## Image Gallery with Caching

```qml
import QtQuick
import QtQuick.Controls
import QuickSearch

GridView {
    cellWidth: 200
    cellHeight: 200

    model: FileSystemModel {
        path: "/home/user/Pictures"
        recursive: true
        filter: FileSystemModel.Images
        maxResults: 100
    }

    delegate: Item {
        width: 200
        height: 200

        Image {
            id: img
            anchors.fill: parent
            anchors.margins: 5
            fillMode: Image.PreserveAspectFit

            CachingImageManager {
                item: img
                cacheDir: "file:///tmp/thumbnails"
                path: modelData.path
            }

            source: cachePath
        }

        Text {
            anchors.bottom: parent.bottom
            text: modelData.name
        }
    }
}
```

---

# Quick Reference

## Default Values

```qml
FileSystemModel {
    recursive: false
    watchChanges: true
    showHidden: false
    sortReverse: false
    minScore: 0.3
    maxDepth: -1      // unlimited
    maxResults: -1    // unlimited
    filter: FileSystemModel.NoFilter
}
```

## Filter Enum Values

```
FileSystemModel.NoFilter       - All entries
FileSystemModel.Files          - Only files
FileSystemModel.Dirs           - Only directories
FileSystemModel.Images         - Only images
FileSystemModel.Applications   - Installed applications (XDG)
```

## Property Change Signals

All properties automatically emit `<propertyName>Changed()` signals for reactive QML binding.

## Performance Best Practices

1. **Limit search depth**: `maxDepth: 3` for large directory trees
2. **Limit results**: `maxResults: 100` to stop early
3. **Use specific filters**: `filter: FileSystemModel.Files` to reduce candidates
4. **Increase minScore**: `minScore: 0.5` for stricter matching
5. **Use nameFilters**: `nameFilters: ["*.txt"]` to narrow down file types
6. **Cache images**: Use `CachingImageManager` for image-heavy applications

## Model/Delegate Access

```qml
// In ListView delegate:
modelData.path        // Access FileSystemEntry properties
modelData.name
modelData.size

// Direct access:
searchModel.entries.length    // Number of results
searchModel.entries[0].path   // First result
```
