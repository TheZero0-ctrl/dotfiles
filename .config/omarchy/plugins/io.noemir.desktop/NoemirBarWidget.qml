import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
    id: root

    moduleName: "io.noemir.desktop"
    visible: status.backgroundThinking
    implicitWidth: visible ? content.implicitWidth + Style.space(12) : 0
    implicitHeight: barSize

    StatusSocket {
        id: status
    }

    Row {
        id: content

        anchors.centerIn: parent
        spacing: Style.space(6)

        Text {
            id: glyph

            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: "\uf5dc"
            color: root.bar ? root.bar.barForeground : Color.foreground
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body

            SequentialAnimation on opacity {
                running: root.visible
                loops: Animation.Infinite
                onRunningChanged: {
                    if (!running)
                        glyph.opacity = 1;
                }

                NumberAnimation {
                    from: 0.5
                    to: 1
                    duration: 720
                    easing.type: Easing.InOutSine
                }

                NumberAnimation {
                    from: 1
                    to: 0.5
                    duration: 720
                    easing.type: Easing.InOutSine
                }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: !root.bar || !root.bar.vertical
            textFormat: Text.PlainText
            text: "Thinking"
            color: root.bar ? root.bar.barForeground : Color.foreground
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body
        }
    }
}
