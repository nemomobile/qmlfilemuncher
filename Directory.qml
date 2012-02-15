import QtQuick 1.1
import com.nokia.meego 1.1
import FBrowser 1.0

Page {
    id: page
    property alias path: dirModel.path
    property bool isRootDirectory: false

    Rectangle {
        id: header
        height: window.inPortrait ? 72 : 0
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

    ListView {
        anchors.top: header.bottom
        anchors.bottom: page.bottom
        anchors.left: page.left
        anchors.right: page.right
        clip: true

        model: DirModel {
            id: dirModel
        }
        delegate: Item {
            width: parent.width
            height: 100

            Image {
                id: icon
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                source: model.iconSource
                asynchronous: true
                height: 80
                width: 80
                fillMode: Image.PreserveAspectCrop
                clip: true
            }

            Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: icon.right
                anchors.right: parent.right
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                text: model.fileName
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (model.isDir)
                        window.cdInto(model.filePath)
                    else
                        dirModel.openFile(model.filePath)
                }
            }
        }
    }

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "icon-m-toolbar-back"
            onClicked: pageStack.pop()
            visible: !page.isRootDirectory
        }
    }

}

