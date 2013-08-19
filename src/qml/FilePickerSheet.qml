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

Sheet {
    id: sheet
    property QtObject model
    property string pickText
    property variant pickedPaths: []
    signal picked(variant pathList)

    acceptButtonText: pickText
    rejectButtonText: "Cancel"

    content: Flickable {
        anchors.fill: parent

        ListView {
            anchors.fill: parent
            model: sheet.model
            delegate: FileListDelegate {
                navigationMode: false

                onClicked: {
                    selected = !selected

                    // TODO: inefficient (http://doc.qt.nokia.com/4.7-snapshot/qml-variant.html)
                    var items = sheet.pickedPaths

                    if (selected) {
                        items[items.length] = model.filePath
                    } else {
                        for (var i = 0; i < items.length; ++i) {
                            if (items[i] == model.filePath) {

                                var rest = items.slice(i + 1);
                                items.length = i < 0 ? items.length + i : i;
                                items = rest.concat(items)
                                break;
                            }
                        }
                    }

                    sheet.pickedPaths = items
                    console.log(sheet.pickedPaths)
                }
            }
        }
    }

    onAccepted: sheet.picked(pickedPaths)
}
