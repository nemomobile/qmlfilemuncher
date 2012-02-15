import QtQuick 1.1
import com.nokia.meego 1.1

PageStackWindow {
    id: window

    initialPage: Directory {
        id: directory

        Component.onCompleted: {
            directory.path = "/home/burchr"
        }
    }
}
