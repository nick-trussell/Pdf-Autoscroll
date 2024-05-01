// Copyright (C) 2022 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Pdf
import QtQuick.Shapes

ApplicationWindow {
    id: root
    width: 800
    height: 1024
    color: "lightgrey"
    title: doc.title
    visible: true
    property string source // for main.cpp

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            anchors.rightMargin: 6
            ToolButton {
                action: Action {
                    shortcut: StandardKey.Open
                    icon.source: "qrc:/singlepage/resources/document-open.svg"
                    onTriggered: fileDialog.open()
                }
                ToolTip.visible: enabled && hovered
                ToolTip.delay: 1000
                ToolTip.text: "Open File"
            }
            ToolButton {
                action: Action {
                    shortcut: StandardKey.ZoomIn
                    enabled: view.renderScale < 10
                    icon.source: "qrc:/singlepage/resources/zoom-in.svg"
                    onTriggered: view.renderScale *= Math.sqrt(2)
                }
                ToolTip.visible: enabled && hovered
                ToolTip.delay: 1000
                ToolTip.text: "Zoom In"
            }
            ToolButton {
                action: Action {
                    shortcut: StandardKey.ZoomOut
                    enabled: view.renderScale > 0.1
                    icon.source: "qrc:/singlepage/resources/zoom-out.svg"
                    onTriggered: view.renderScale /= Math.sqrt(2)
                }
                ToolTip.visible: enabled && hovered
                ToolTip.delay: 1000
                ToolTip.text: "Zoom Out"
            }
            ToolButton {
                action: Action {
                    icon.source: "qrc:/singlepage/resources/zoom-fit-width.svg"
                    onTriggered: view.scaleToWidth(root.contentItem.width, root.contentItem.height)
                }
                ToolTip.visible: enabled && hovered
                ToolTip.delay: 1000
                ToolTip.text: "Fit Width"
            }
            ToolButton {
                action: Action {
                    icon.source: "qrc:/singlepage/resources/zoom-fit-best.svg"
                    onTriggered: view.scaleToPage(root.contentItem.width, root.contentItem.height)
                }
                ToolTip.visible: enabled && hovered
                ToolTip.delay: 1000
                ToolTip.text: "Best Fit"
            }
            ToolButton {
                action: Action {
                    shortcut: "Ctrl+0"
                    icon.source: "qrc:/singlepage/resources/zoom-original.svg"
                    onTriggered: view.resetScale()
                }
                ToolTip.visible: enabled && hovered
                ToolTip.delay: 1000
                ToolTip.text: "reset zoom"
            }
            ToolButton {
                action: Action {
                    icon.source: "qrc:/singlepage/resources/go-previous-view-page.svg"
                    enabled: view.backEnabled
                    onTriggered: view.back()
                }
                ToolTip.visible: enabled && hovered
                ToolTip.delay: 2000
                ToolTip.text: "go back"
            }
            SpinBox {
                id: currentPageSB
                from: 1
                to: doc.pageCount
                editable: true
                onValueModified: view.goToPage(value - 1)
                Shortcut {
                    sequence: StandardKey.MoveToPreviousPage
                    onActivated: view.goToPage(currentPageSB.value - 2)
                }
                Shortcut {
                    sequence: StandardKey.MoveToNextPage
                    onActivated: view.goToPage(currentPageSB.value)
                }
            }
            ToolButton {
                action: Action {
                    icon.source: "qrc:/singlepage/resources/go-next-view-page.svg"
                    enabled: view.forwardEnabled
                    onTriggered: view.forward()
                }
                ToolTip.visible: enabled && hovered
                ToolTip.delay: 2000
                ToolTip.text: "go forward"
            }
            ToolButton {
                action: Action {
                    icon.source: "qrc:/singlepage/resources/play-icon.svg"
                    onTriggered: {
                        view.flickPages(0, -(scrollSpeed.value))
                    }
                }
                ToolTip.visible: enabled && hovered
                ToolTip.delay: 1000
                ToolTip.text: "Flick"
            }
            Slider {
                id: scrollSpeed
                from: 10
                value: 13
                to: 30
                ToolTip.visible: enabled && hovered
                ToolTip.delay: 1000
                ToolTip.text: scrollSpeed.value
            }
            Shortcut {
                sequence: StandardKey.Quit
                onActivated: Qt.quit()
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Open a PDF file"
        nameFilters: [ "PDF files (*.pdf)" ]
        onAccepted: doc.source = selectedFile
    }

    Dialog {
        id: passwordDialog
        title: "Password"
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        closePolicy: Popup.CloseOnEscape
        anchors.centerIn: parent
        width: 300

        contentItem: TextField {
            id: passwordField
            placeholderText: qsTr("Please provide the password")
            echoMode: TextInput.Password
            width: parent.width
            onAccepted: passwordDialog.accept()
        }
        onOpened: passwordField.forceActiveFocus()
        onAccepted: doc.password = passwordField.text
    }

    Dialog {
        id: errorDialog
        title: "Error loading " + doc.source
        standardButtons: Dialog.Close
        modal: true
        closePolicy: Popup.CloseOnEscape
        anchors.centerIn: parent
        width: 300
        visible: doc.status === PdfDocument.Error

        contentItem: Label {
            id: errorField
            text: doc.error
        }
    }

    PdfDocument {
        id: doc
        source: Qt.resolvedUrl(root.source)
        onPasswordRequired: passwordDialog.open()
    }

    PdfMultiPageViewFlick {
        id: view
        anchors.fill: parent
        document: doc
        onCurrentPageChanged: currentPageSB.value = view.currentPage + 1
    }

    DropArea {
        anchors.fill: parent
        keys: ["text/uri-list"]
        onEntered: (drag) => {
            drag.accepted = (drag.proposedAction === Qt.MoveAction || drag.proposedAction === Qt.CopyAction) &&
                drag.hasUrls && drag.urls[0].endsWith("pdf")
        }
        onDropped: (drop) => {
            doc.source = drop.urls[0]
            drop.acceptProposedAction()
        }
    }

}


