cmake_minimum_required(VERSION 3.16)
project(quicksearch VERSION 1.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Qml Quick Concurrent)

qt_add_qml_module(quicksearch
    URI QuickSearch
    VERSION 1.0
    SOURCES
        quicksearch.cpp quicksearch.h
        models/filesystemmodel.cpp models/filesystemmodel.hpp
        models/fuzzysearch.cpp models/fuzzysearch.hpp
        models/desktopentry.cpp models/desktopentry.hpp
        internal/cachingimagemanager.cpp internal/cachingimagemanager.hpp
)

target_link_libraries(quicksearch PRIVATE Qt6::Core Qt6::Qml Qt6::Quick Qt6::Concurrent)

set_target_properties(quicksearchplugin PROPERTIES
    INSTALL_RPATH "$ORIGIN"
)

install(TARGETS quicksearch quicksearchplugin
    LIBRARY DESTINATION lib/qml/QuickSearch
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/qmldir
    DESTINATION lib/qml/QuickSearch
)
