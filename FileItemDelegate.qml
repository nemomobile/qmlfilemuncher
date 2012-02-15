import QtQuick 1.1
import com.nokia.meego 1.1

Item {
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
        anchors.right: drilldown.left
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        text: model.fileName
    }

    Image {
        id: drilldown
        visible: model.isDir
        source: "image://theme/icon-m-common-drilldown-arrow" + (theme.inverted ? "-inverse" : "")
        anchors.right: parent.right;
        anchors.verticalCenter: parent.verticalCenter
    }
}

