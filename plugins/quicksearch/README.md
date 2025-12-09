# QuickSearch QML Plugin

File/app search plugin for Quickshell with fuzzy search capabilities.

A large part of the code in this project is sourced from https://github.com/caelestia-dots/shell and much credit is due to https://github.com/soramanew for much of the hard work which made this possible.

## Features

- **Fuzzy Search**: Smart substring matching with relevance scoring
- **Reactive Updates**: Model updates automatically when inputs change
- **Filesystem Watching**: Detects file changes in real-time
- **Filtering**: Filter by file type, extensions, and more
- **Recursive Search**: Search through entire directory trees
- **Performance Optimizations**: Depth limiting, result limiting, and score caching
- **Async Operations**: Non-blocking searches using Qt Concurrent
- **QML Integration**: Easy-to-use QML components

## Build Instructions

```bash
# Build
cmake -B build -DCMAKE_INSTALL_PREFIX=$HOME/.local
cmake --build build

# Install
cmake --install build

# The plugin will be installed to:
# $HOME/.local/lib/qml/QuickSearch/
```

## Usage in QML

Set `QML_IMPORT_PATH` environment variable:
```bash
export QML_IMPORT_PATH=$HOME/.local/lib/qml
```

### Basic Example

```qml
import QtQuick
import QuickSearch

FileSystemModel {
    id: searchModel
    path: "/home/user/Documents"
    recursive: true
    query: "myfile"  // Fuzzy search query
}

ListView {
    model: searchModel
    delegate: Text {
        text: modelData.name + " - " + modelData.path
    }
}
```

### Full Example

See `example.qml` for a complete working example with:
- Search input field
- Real-time filtering
- File type indicators
- Configurable options

Run the example:
```bash
qml6 example.qml
```

## API Reference

### FileSystemModel

A QML model for searching and listing files with fuzzy search capabilities.

#### Properties

- **`path: string`** - Root directory to search in
- **`recursive: bool`** - Search subdirectories recursively (default: `false`)
- **`watchChanges: bool`** - Watch for filesystem changes (default: `true`)
- **`showHidden: bool`** - Include hidden files (default: `false`)
- **`sortReverse: bool`** - Reverse sort order (default: `false`)
- **`query: string`** - Fuzzy search query (empty = show all files)
- **`minScore: double`** - Minimum fuzzy match score, 0.0 to 1.0 (default: `0.3`)
- **`maxDepth: int`** - Maximum recursion depth, -1 for unlimited (default: `-1`)
- **`maxResults: int`** - Maximum number of results, -1 for unlimited (default: `-1`)
- **`filter: Filter`** - Filter by type:
  - `FileSystemModel.NoFilter` - Show all
  - `FileSystemModel.Files` - Only files
  - `FileSystemModel.Dirs` - Only directories
  - `FileSystemModel.Images` - Only images
- **`nameFilters: list<string>`** - File extension filters (e.g., `["*.txt", "*.md"]`)
- **`entries: list<FileSystemEntry>`** - List of matching entries (read-only)

#### FileSystemEntry Properties

Each entry in the model has:

- **`path: string`** - Absolute file path
- **`relativePath: string`** - Path relative to search root
- **`name: string`** - File name with extension
- **`baseName: string`** - File name without extension
- **`parentDir: string`** - Parent directory path
- **`suffix: string`** - File extension
- **`size: int`** - File size in bytes
- **`isDir: bool`** - Is directory
- **`isImage: bool`** - Is readable image
- **`mimeType: string`** - MIME type

### Fuzzy Search Algorithm

The fuzzy search algorithm scores matches based on:
1. **Character Matching** (40%) - All query characters found in order
2. **Prefix Matching** (30%) - Query matches start of filename
3. **Consecutive Characters** (20%) - Characters appear consecutively
4. **Match Position** (10%) - Matches appear earlier in filename

Score range: 0.0 (no match) to 1.0 (perfect match)

## Examples

### Search for text files

```qml
FileSystemModel {
    path: "/home/user"
    recursive: true
    filter: FileSystemModel.Files
    nameFilters: ["*.txt", "*.md"]
    query: "readme"
}
```

### Search for images

```qml
FileSystemModel {
    path: "/home/user/Pictures"
    recursive: true
    filter: FileSystemModel.Images
    query: "vacation"
}
```

### List all files (no search)

```qml
FileSystemModel {
    path: "/home/user/Projects"
    recursive: true
    // Empty query shows all files
}
```

### Adjust search sensitivity

```qml
FileSystemModel {
    path: "/home/user"
    recursive: true
    query: "doc"
    minScore: 0.5  // Stricter matching (fewer results)
    // minScore: 0.1  // Looser matching (more results)
}
```

### Performance optimization for large directories

```qml
FileSystemModel {
    path: "/home/user"
    recursive: true
    query: "config"

    // Performance options
    maxDepth: 3      // Only search 3 levels deep
    maxResults: 100  // Stop after finding 100 matches

    // These significantly improve performance on large directory trees
}
```

## Performance Tips

- **Use `maxDepth`** to limit how deep recursive searches go (e.g., `maxDepth: 3` for 3 levels)
- **Use `maxResults`** to limit total results returned (e.g., `maxResults: 100`)
- **Increase `minScore`** to reduce the number of weak matches
- **Use `nameFilters`** to narrow down file types before searching
- Fuzzy match scores are automatically cached to avoid recalculation

## License

GPL-3.0 - See original projects for attribution
