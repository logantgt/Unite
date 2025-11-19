import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    anchors {
        left: parent.left
        right: parent.right
    }

    implicitHeight: 162

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 26
        anchors.rightMargin: 26
        color: "#20000000"


        Column {
            id: calendarBase
            anchors.fill: parent

            RowLayout {
                spacing: 0
                uniformCellSizes: false
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 12
                }
                height: 16

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 20

                    Button {
                        anchors.fill: parent
                        background: Item {}
                        contentItem: Text {
                            anchors.fill: parent
                            text: "◂"
                            color: "white"
                            font.family: "Ubuntu"
                        }
                        onClicked: {
                            if(grid.month - 1 == -1) {
                                grid.year--;
                                grid.month = 11;
                            } else {
                                grid.month--;
                            }
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: mtdisp.implicitWidth

                    Text {
                        id: mtdisp
                        anchors.fill: parent
                        anchors.leftMargin: -6
                        text: Qt.locale().standaloneMonthName(grid.month);
                        color: "white"
                        font.family: "Ubuntu"
                        verticalAlignment: Text.AlignBottom
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 20
                    Layout.alignment: Qt.AlignVCenter

                    Button {
                        anchors.fill: parent
                        background: Item {}
                        contentItem: Text {
                            anchors.fill: parent
                            text: "▸"
                            color: "white"
                            font.family: "Ubuntu"
                        }
                        onClicked: {
                            if(grid.month + 1 == 12) {
                                grid.year++;
                                grid.month = 0;
                            } else {
                                grid.month++;
                            }
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 20

                    Button {
                        anchors.fill: parent
                        background: Item {}
                        contentItem: Text {
                            anchors.fill: parent
                            text: "◂"
                            color: "white"
                            font.family: "Ubuntu"
                        }
                        onClicked: { grid.year--; }
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: yrdisp.implicitWidth


                    Text {
                        id: yrdisp
                        anchors.fill: parent
                        anchors.leftMargin: -6
                        text: grid.year
                        color: "white"
                        font.family: "Ubuntu"
                        verticalAlignment: Text.AlignBottom
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 20

                    Button {
                        anchors.fill: parent
                        background: Item {}
                        contentItem: Text {
                            anchors.fill: parent
                            text: "▸"
                            color: "white"
                            font.family: "Ubuntu"
                        }
                        onClicked: { grid.year++; }
                    }
                }
            }

            DayOfWeekRow {
                id: row
                anchors {
                    left: parent.left
                    right: parent.right
                }
                anchors.margins: 4
                locale: Qt.locale("en_US")
                delegate: Text {
                    text: shortName
                    font.family: "Ubuntu"
                    font.bold: true
                    color: "white"
                }

                Rectangle {
                    color: "#10ffffff"
                    anchors.centerIn: row
                    width: calendarBase.width - 8
                    height: row.height - 8
                }
            }

            MonthGrid {
                id: grid
                anchors {
                    left: parent.left
                    right: parent.right
                }
                locale: Qt.locale("en_US")
                delegate: Rectangle {
                    width: 14
                    height: 14
                    color: model.today ? "#30ffffff" : "transparent"
                    Text {
                        anchors.fill: parent
                        text: grid.locale.toString(model.date, "d")
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: "Ubuntu"
                        color: "white"
                        opacity: model.month === grid.month ? 1 : 0.5
                    }
                }
            }
        }
    }
}
