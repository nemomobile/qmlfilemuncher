/*
 * Copyright (C) 2012 Petri M. Gerdt <petri.gerdt@gmail.com>
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

Rectangle {
    property int pixelSize
    property bool isReadable: false
    property bool isWritable: false
    property bool isExecutable: false
    property bool isDir: false

    property int padding: label.font.pixelSize / 2
    property int side: label.width > label.height ? label.width : label.height

    width: padding + side
    height: width
    radius: width / 2

    Label {
        id: label
        anchors.centerIn: parent
        text: ""
        font.pixelSize: parent.pixelSize;
    }

    Image {
        anchors.fill: parent
        source: "qrc:/qml/prohibitionsign.svg"
        sourceSize: Qt.size(parent.width, parent.height)
        clip: true
    }

    Component.onCompleted: {
        if (!isReadable)
            label.text += "r";
        if (!isWritable)
            label.text += "w";
        if (isDir && !isExecutable)
            label.text += "x";
    }
}
