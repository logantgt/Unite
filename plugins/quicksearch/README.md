# QuickSearch QML Plugin

File/app search plugin for Quickshell with fuzzy search capabilities.

A large part of the code in this project is sourced from https://github.com/caelestia-dots/shell and much credit is due to https://github.com/soramanew for much of the hard work which made this possible.

Vibe coded, undergoing testing and verification.

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

## License

GPL-3.0 - See original projects for attribution
