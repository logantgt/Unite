# QuickSearch QML Plugin

File/app search plugin for Quickshell.

A large part of the code in this project is sourced from https://github.com/caelestia-dots/shell and much credit is due to https://github.com/soramanew for much of the hard work which made this possible.

## Build Instructions

```bash
# Build
cmake -B build -DCMAKE_INSTALL_PREFIX=$HOME/.local
cmake --build build

# Install
cmake --install build

# The plugin will be installed to:
# $HOME/.local/lib/qml/Quicksearch/
```

## Usage in QML
Set `QML_IMPORT_PATH` environment variable:
```bash
export QML_IMPORT_PATH=$HOME/.local/lib/qml
```
