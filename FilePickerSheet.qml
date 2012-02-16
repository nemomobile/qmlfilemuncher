import QtQuick 1.1
import com.nokia.meego 1.1

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
            delegate: FileItemDelegate {
                navigationMode: false

                MouseArea {
                    anchors.fill: parent
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
    }

    onAccepted: sheet.picked(pickedPaths)
}
