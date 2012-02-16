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
        delegate: FileItemDelegate {
            // TODO: can we make this more generic?
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

        ToolIcon {
            iconId: "icon-m-toolbar-refresh"
            onClicked: dirModel.refresh()
        }

        ToolIcon {
            iconId: "icon-m-toolbar-view-menu"
            onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }

    Menu {
        id: myMenu
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
                    }
                }
            }
        }
    }
}

