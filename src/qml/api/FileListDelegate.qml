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

Rectangle {
    id: delegate
    property bool navigationMode: true
    property bool selected: false
    width: parent.width
    height: UiConstants.ListItemHeightDefault
    color: selected ? "#800000FF" : "transparent"

    signal clicked()
    signal pressAndHold()

    Image {
        id: icon
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: UiConstants.DefaultMargin
        source: model.iconSource
        asynchronous: true
        height: UiConstants.ListItemHeightSmall
        width: UiConstants.ListItemHeightSmall
        sourceSize: Qt.size(width, height)
        clip: true
    }

    Loader {
        anchors { bottom: icon.bottom; right: icon.right }
        sourceComponent: !model.isReadable || !model.isWritable
                         || (model.isDir && !model.isExecutable)
                         ? permissions : undefined
    }

    Component {
        id: permissions

        FilePermissionIndicator {
            pixelSize: fileName.font.pixelSize / 1.7
            isReadable: model.isReadable
            isWritable: model.isWritable
            isExecutable: model.isExecutable
            isDir: model.isDir
        }
    }

    Label {
        id: fileName
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: icon.right
        anchors.right: model.isFile ? fileSize.left : drillDown.left
        anchors.leftMargin: UiConstants.DefaultMargin
        anchors.rightMargin: UiConstants.DefaultMargin
        text: model.fileName
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
    }

    Text {
        id: fileSize
        color: "#8e8e8e"
        visible: model.isFile
        font: UiConstants.SubtitleFont
        text: model.fileSize
        anchors.right: parent.right
        anchors.rightMargin: UiConstants.DefaultMargin
        anchors.verticalCenter: parent.verticalCenter
    }

    Image {
        id: drillDown
        visible: model.isDir && navigationMode
        source: "image://theme/icon-m-common-drilldown-arrow" + (theme.inverted ? "-inverse" : "")
        anchors.right: parent.right;
        anchors.rightMargin: UiConstants.DefaultMargin
        anchors.verticalCenter: parent.verticalCenter
        asynchronous: true
        cache: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            delegate.clicked()
        }

        onPressAndHold: {
            delegate.pressAndHold()
        }
    }
}

