cmake_minimum_required(VERSION 3.16)
project(quicksearch VERSION 1.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Qml)

qt_add_qml_module(quicksearch
    URI QuickSearch
    VERSION 1.0
    SOURCES
        quicksearch.cpp quicksearch.h
)

target_link_libraries(quicksearch PRIVATE Qt6::Core Qt6::Qml)

set_target_properties(quicksearchplugin PROPERTIES
    INSTALL_RPATH "$ORIGIN"
)

install(TARGETS quicksearch quicksearchplugin
    LIBRARY DESTINATION lib/qml/QuickSearch
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/qmldir
    DESTINATION lib/qml/QuickSearch
)
