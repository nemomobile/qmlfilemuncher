/*
 * Copyright (C) 2012 Robin Burchell <robin+nemo@viroteck.net>
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * Neither the name of Nemo Mobile nor the names of its contributors
 *     may be used to endorse or promote products derived from this
 *     software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */

import QtQuick 2.0
import com.nokia.meego 2.0
import org.nemomobile.folderlistmodel 1.0
import org.nemomobile.qmlfilemuncher 1.0

Page {
    id: page
    property alias path: dirModel.path
    property bool isRootDirectory: false
    property string selectedFile
    property string selectedFilePath
    property int selectedRow

    Rectangle {
        id: header
        height: window.inPortrait ? 72 : 0
        visible: window.inPortrait ? true : false
        color: "#EA650A"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        property alias content: othercontent.children

        Item {
            id: othercontent
            width: childrenRect.width
            height: childrenRect.height
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }

        Label {
            id: label
            anchors.left: othercontent.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            smooth: true
            color: "white"
            text: dirModel.path
            elide: Text.ElideLeft
        }
    }

    ScrollDecorator {
        flickableItem: fileList
    }

    ListView {
        id: fileList
        anchors.top: header.bottom
        anchors.bottom: page.bottom
        anchors.left: page.left
        anchors.right: page.right
        clip: true

        model: FolderListModel {
            id: dirModel
        }
        delegate: FileListDelegate {
            onClicked: {
                if (model.isDir)
                    window.cdInto(model.filePath)
                else {
                    page.selectedFilePath = model.filePath
                    openFileDialog.open()
                }
            }

            onPressAndHold: {
                page.selectedFile = model.filePath;
                page.selectedRow = model.index;
                console.log("tapping on " + page.selectedRow)
                if (tapMenu.status == DialogStatus.Closed)
                    tapMenu.open()
                else
                    tapMenu.close()
            }
        }
    }

    ViewPlaceholder {
        text: "No files here"
        enabled: !dirModel.awaitingResults && fileList.count == 0 ? true : false
    }

    BusyIndicator {
        anchors.centerIn: parent
        visible: dirModel.awaitingResults && fileList.count == 0 ? true : false
        platformStyle: BusyIndicatorStyle {
            size: "large"
        }
    }

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "icon-m-toolbar-back"
            onClicked: pageStack.pop()
            visible: !page.isRootDirectory
        }

        ToolIcon {
            iconId: "icon-m-toolbar-refresh"
            onClicked: dirModel.refresh()
        }

        ToolIcon {
            iconId: "icon-m-toolbar-view-menu"
            onClicked: (pageMenu.status == DialogStatus.Closed) ? pageMenu.open() : pageMenu.close()
        }
    }

    // TODO: create menus only when needed, and share between pages
    Menu {
        id: pageMenu
        MenuLayout {
                MenuItem { text: "Delete items"; onClicked: {
                    var component = Qt.createComponent("FilePickerSheet.qml");
                    if (component.status == Component.Ready) {
                        // TODO: error handling
                        var deletePicker = component.createObject(page, {"model": dirModel, "pickText": "Delete"});
                        deletePicker.picked.connect(function(files) {
                            console.log("deleting " + files)
                            dirModel.rm(files)
                        });
                        deletePicker.open()
                    } else {
                        console.log("Delete Items: " + component.errorString())
                    }
                }
            }
            MenuItem {
                text: "Create new folder"
                onClicked: {
                    var component = Qt.createComponent("InputSheet.qml");
                    if (component.status == Component.Ready) {
                        // TODO: error handling
                        var newFolder = component.createObject(page, {"title": "Enter new folder name"});
                        newFolder.accepted.connect(function() {
                            var folderName = newFolder.inputText
                            console.log("Creating new folder " + folderName)
                            dirModel.mkdir(folderName)
                        });
                        newFolder.open()
                    }
                }
            }
        }
    }

    Menu {
        id: tapMenu
        MenuLayout {
            MenuItem {
                text: "Details"
                onClicked: {
                    var component = Qt.createComponent("DetailViewSheet.qml");
                    console.log(component.errorString())
                    if (component.status == Component.Ready) {
                        // TODO: error handling
                        var detailsSheet = component.createObject(page, {"model": dirModel, "selectedRow": page.selectedRow});
                        detailsSheet.open()
                    }
                }
            }

            MenuItem {
                text: "Delete"
                onClicked: dirModel.rm(selectedFile)
            }
        }
    }

    QueryDialog {
        id: openFileDialog
        message: "Open file: " + page.selectedFilePath
        acceptButtonText: "Yes"
        rejectButtonText: "No"
        onAccepted: {
            Qt.openUrlExternally("file://" + page.selectedFilePath )
        }
    }

    QueryDialog {
        id: errorDialog
        acceptButtonText: "Ok"
    }

    Connections {
        target: dirModel
        onError: {
            errorDialog.titleText = errorTitle
            errorDialog.message = errorMessage
            errorDialog.open()
        }
    }

}

