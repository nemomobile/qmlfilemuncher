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

import QtQuick 1.1
import com.nokia.meego 1.0
import FBrowser 1.0

Sheet {
    id: sheet
    property QtObject model
    property int selectedRow
//    acceptButtonText: "Save"
    rejectButtonText: "Close"

    Component.onCompleted: {
        // we should only enable this if there is something to save, and if
        // there is, we also need to change "Close" to "Cancel" on
        // rejectButtonText
        acceptButton.enabled = false
    }

    content: Flickable {
        anchors { margins: UiConstants.DefaultMargin; fill:parent }

        Column {
            anchors.fill: parent

            Item {
                id: nameContainer
                height: 60
                anchors.left: parent.left
                anchors.right: parent.right

                Label {
                    id: nameLabel
                    text: "Name:"
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label {
                    id: nameField
                    text: model.data(sheet.selectedRow, "fileName")
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                id: pathContainer
                height: 60
                anchors.left: parent.left
                anchors.right: parent.right

                Label {
                    id: pathLabel
                    text: "Path:"
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label {
                    id: pathField
                    text: model.data(sheet.selectedRow, "filePath")
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                id: sizeContainer
                height: 60
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: UiConstants.DefaultMargin
                visible: model.data(sheet.selectedRow, "isFile")

                Label {
                    id: sizeLabel
                    text: "Size:"
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label {
                    id: sizeField
                    text: model.data(sheet.selectedRow, "fileSize")
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                id: createdContainer
                height: 60
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: UiConstants.DefaultMargin

                Label {
                    id: createdLabel
                    text: "Created:"
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label {
                    id: createdField
                    text: model.data(sheet.selectedRow, "creationDate")
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                id: modifiedContainer
                height: 60
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: UiConstants.DefaultMargin

                Label {
                    id: modifiedLabel
                    text: "Last Modified:"
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label {
                    id: modifiedField
                    text: model.data(sheet.selectedRow, "modifiedDate")
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}

