import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

Item {
    id: root

    property var connectionSettings: ({})
    readonly property bool opened: chat.opened

    readonly property var record: status.record
    property string lastBusyRevision: ""
    property string lastErrorRevision: ""
    property bool noticeFlash: false
    property bool errorFlash: false
    property real shakeOffset: 0
    readonly property string state: !record ? "idle" : record.state === "delivering_check_in" ? "speaking" : record.state === "check_in_pending" ? "idle" : record.state
    readonly property bool shown: record !== null && state !== "idle"
    readonly property color stateColor: state === "error" ? Color.urgent : state === "listening" ? Color.accent : Color.popups.text
    readonly property color feedbackColor: errorFlash ? Color.urgent : noticeFlash ? Color.accent : stateColor

    function observeRecord(parsed) {
        if (!parsed) {
            lastBusyRevision = "";
            lastErrorRevision = "";
            return;
        }
        var revision = String(parsed.revision);
        if (parsed.notice === "busy" && revision !== lastBusyRevision) {
            lastBusyRevision = revision;
            noticeFlash = true;
            noticeTimer.restart();
            shake.restart();
        }
        if (parsed.state === "error" && revision !== lastErrorRevision) {
            lastErrorRevision = revision;
            errorFlash = true;
            errorTimer.restart();
            shake.restart();
        }
    }

    function open(payloadJson) {
        status.reconnect();
        var payload = {};
        try { payload = JSON.parse(payloadJson || "{}"); } catch (e) {}
        if (payload.mode === "text") {
            if (chat.opened)
                chat.close();
            var connection = {};
            ["binary", "home", "serverUrl"].forEach(function(key) {
                if (typeof payload[key] === "string")
                    connection[key] = payload[key];
            });
            connectionSettings = connection;
            chat.open();
        }
    }

    function close() {
        chat.close();
    }

    ChatPanel {
        id: chat
        settings: root.connectionSettings
    }

    function iconFor(value) {
        if (value === "starting")
            return "\uf110";

        if (value === "listening")
            return "\uf130";

        if (value === "transcribing")
            return "\uf15c";

        if (value === "thinking")
            return "\uf5dc";

        if (value === "speaking")
            return "\uf028";

        if (value === "error")
            return "\uf071";

        return "";
    }

    function labelFor(value) {
        if (value === "starting")
            return "Starting";

        if (value === "listening")
            return "Listening";

        if (value === "transcribing")
            return "Transcribing";

        if (value === "thinking")
            return "Thinking";

        if (value === "speaking")
            return "Speaking";

        if (value === "error")
            return "Unavailable";

        return "";
    }

    function modeSuffix() {
        if (!record || state !== "listening")
            return "";

        if (record.mode === "tap")
            return "  \u00b7  tap";

        if (record.mode === "push_to_talk")
            return "  \u00b7  hold";

        return "";
    }

    StatusSocket {
        id: status

        onRecordChanged: root.observeRecord(record)
    }

    Timer {
        id: noticeTimer

        interval: 520
        onTriggered: root.noticeFlash = false
    }

    Timer {
        id: errorTimer

        interval: 720
        onTriggered: root.errorFlash = false
    }

    SequentialAnimation {
        id: shake

        NumberAnimation {
            target: root
            property: "shakeOffset"
            to: -5
            duration: 45
            easing.type: Easing.OutQuad
        }

        NumberAnimation {
            target: root
            property: "shakeOffset"
            to: 5
            duration: 70
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: root
            property: "shakeOffset"
            to: 0
            duration: 75
            easing.type: Easing.OutQuad
        }

    }

    PanelWindow {
        id: panel

        visible: root.shown
        color: "transparent"
        WlrLayershell.namespace: "noemir-desktop-status"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            right: true
            bottom: true
            left: true
        }

        BorderSurface {
            id: card

            readonly property int padX: Style.space(14)
            readonly property int padY: Style.space(9)

            width: content.implicitWidth + padX * 2 + borderLeft + borderRight
            height: Math.max(Style.space(42), content.implicitHeight + padY * 2 + borderTop + borderBottom)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Style.space(67)
            radius: Style.cornerRadius
            color: Util.alpha(Color.popups.background, 0.96)
            borderSpec: Border.surfaceSpec("popups", "border", root.noticeFlash || root.errorFlash ? root.feedbackColor : Color.popups.border, Math.max(1, Style.space(1)))

            Rectangle {
                width: Math.max(Style.space(2), 2)
                height: parent.height - card.borderTop - card.borderBottom
                x: card.borderLeft
                y: card.borderTop
                color: root.feedbackColor
                opacity: root.noticeFlash || root.errorFlash ? 1 : 0.72
            }

            Row {
                id: content

                anchors.centerIn: parent
                spacing: Style.space(9)

                Item {
                    width: Style.space(24)
                    height: Style.space(24)
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        id: pulse

                        anchors.centerIn: parent
                        width: parent.width
                        height: width
                        radius: width / 2
                        color: "transparent"
                        border.width: Math.max(1, Style.space(1))
                        border.color: Color.accent
                        visible: root.state === "listening"
                        opacity: 0
                        scale: 0.68

                        SequentialAnimation on scale {
                            running: pulse.visible && root.shown
                            loops: Animation.Infinite

                            NumberAnimation {
                                from: 0.68
                                to: 1.18
                                duration: 760
                                easing.type: Easing.OutCubic
                            }

                            PauseAnimation {
                                duration: 140
                            }

                        }

                        SequentialAnimation on opacity {
                            running: pulse.visible && root.shown
                            loops: Animation.Infinite

                            NumberAnimation {
                                from: 0.72
                                to: 0
                                duration: 760
                                easing.type: Easing.OutCubic
                            }

                            PauseAnimation {
                                duration: 140
                            }

                        }

                    }

                    Text {
                        id: icon

                        anchors.centerIn: parent
                        textFormat: Text.PlainText
                        text: root.iconFor(root.state)
                        color: root.stateColor
                        font.family: Style.font.family
                        font.pixelSize: Style.font.heading

                        RotationAnimation on rotation {
                            running: root.shown && root.state === "starting"
                            from: 0
                            to: 360
                            duration: 1100
                            loops: Animation.Infinite
                            direction: RotationAnimation.Clockwise
                        }

                        SequentialAnimation on opacity {
                            running: root.shown && root.state === "thinking"
                            loops: Animation.Infinite
                            onRunningChanged: {
                                if (!running)
                                    icon.opacity = 1;
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

                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    textFormat: Text.PlainText
                    text: root.labelFor(root.state) + root.modeSuffix()
                    color: root.state === "error" ? Color.urgent : Color.popups.text
                    font.family: Style.font.family
                    font.pixelSize: Style.font.title
                    font.bold: true
                }

                Row {
                    id: dots

                    visible: root.state === "transcribing" || root.state === "thinking"
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Style.space(3)

                    Repeater {
                        model: 3

                        Rectangle {
                            required property int index

                            width: Style.space(4)
                            height: width
                            radius: width / 2
                            color: root.stateColor
                            opacity: 0.28

                            SequentialAnimation on opacity {
                                running: dots.visible && root.shown
                                loops: Animation.Infinite

                                PauseAnimation {
                                    duration: index * 140
                                }

                                NumberAnimation {
                                    to: 1
                                    duration: 120
                                    easing.type: Easing.OutQuad
                                }

                                NumberAnimation {
                                    to: 0.28
                                    duration: 120
                                    easing.type: Easing.InQuad
                                }

                                PauseAnimation {
                                    duration: (2 - index) * 140
                                }

                            }

                        }

                    }

                }

                Row {
                    id: waves

                    visible: root.state === "speaking"
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Style.space(2)

                    Repeater {
                        model: 3

                        Rectangle {
                            required property int index

                            width: Style.space(2)
                            height: Style.space(5)
                            radius: width / 2
                            color: Color.accent
                            anchors.verticalCenter: parent.verticalCenter

                            SequentialAnimation on height {
                                running: waves.visible && root.shown
                                loops: Animation.Infinite

                                PauseAnimation {
                                    duration: index * 90
                                }

                                NumberAnimation {
                                    to: Style.space(12)
                                    duration: 170
                                    easing.type: Easing.OutQuad
                                }

                                NumberAnimation {
                                    to: Style.space(5)
                                    duration: 170
                                    easing.type: Easing.InQuad
                                }

                                PauseAnimation {
                                    duration: (2 - index) * 90
                                }

                            }

                        }

                    }

                }

            }

            transform: Translate {
                x: root.shakeOffset
            }

            Behavior on color {
                ColorAnimation {
                    duration: 120
                }

            }

        }

        mask: Region {
        }

    }

}
