import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Ui

Item {
    id: root

    property bool opened: false
    property var settings: ({
    })
    property string draft: ""
    property bool focusPrimed: false
    readonly property bool busy: bridge.sending || bridge.resetting || !!(bridge.conversation && bridge.conversation.active_run) || !!(bridge.status && ["idle", "check_in_pending", "error"].indexOf(bridge.status.phase) < 0)
    readonly property var rows: {
        var output = [];
        var messages = bridge.conversation ? bridge.conversation.messages : [];
        var active = bridge.conversation ? bridge.conversation.active_run : null;
        var savedRunText = false;
        for (var i = 0; i < messages.length; i++) {
            var message = messages[i];
            // The cumulative run snapshot renders the active assistant text.
            if (message.role !== "user" && message.role !== "assistant")
                continue;

            if (message.role === "assistant" && message.run_id === active)
                continue;

            var text = textParts(message);
            if (bridge.run && message.run_id === bridge.run.id && message.role === "assistant" && text)
                savedRunText = true;

            if (text)
                output.push({
                "role": message.role,
                "text": text,
                "status": message.run_status
            });

        }
        if (bridge.run && bridge.conversation && bridge.run.conversation_id === bridge.conversation.id && bridge.run.id === active)
            output.push({
            "role": "assistant",
            "text": bridge.run.text || "Waiting for Noemir…",
            "status": bridge.run.status
        });
        else if (bridge.run && bridge.conversation && bridge.run.conversation_id === bridge.conversation.id && !savedRunText && bridge.run.text)
            output.push({
            "role": "assistant",
            "text": bridge.run.text,
            "status": bridge.run.status
        });
        return output;
    }

    signal dismissed()

    function setting(name, fallback) {
        return settings && settings[name] !== undefined ? settings[name] : fallback;
    }

    function open() {
        opened = true;
        focusPrimed = false;
        focusTimer.restart();
        Qt.callLater(function() {
            editor.forceActiveFocus();
        });
    }

    function close() {
        opened = false;
        dismissed();
    }

    function textParts(message) {
        return (message.content || []).filter(function(part) {
            return part.type === "text";
        }).map(function(part) {
            return part.text;
        }).join("\n");
    }

    ChatBridge {
        id: bridge

        active: root.opened
        binary: root.setting("binary", "noemir")
        home: root.setting("home", "")
        serverUrl: root.setting("serverUrl", "")
        onAccepted: function(content) {
            if (root.draft === content)
                root.draft = "";

        }
    }

    Timer {
        id: focusTimer

        interval: 75
        onTriggered: root.focusPrimed = true
    }

    Shortcut {
        sequence: "Escape"
        enabled: root.opened
        onActivated: root.close()
    }

    PanelWindow {
        id: window

        visible: root.opened
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "noemir-desktop-chat"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.opened ? (root.focusPrimed ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.Exclusive) : WlrKeyboardFocus.None
        implicitWidth: Math.min(Style.space(680), screen ? screen.width - Style.space(40) : Style.space(680))
        implicitHeight: Math.min(Style.space(640), screen ? screen.height - Style.space(100) : Style.space(640))

        BorderSurface {
            anchors.fill: parent
            radius: Style.cornerRadius
            color: Color.popups.background
            borderSpec: Border.surfaceSpec("popups", "border", Color.popups.border, Math.max(1, Style.space(2)))

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.space(18)
                spacing: Style.space(12)

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Noemir"
                        color: Color.popups.text
                        font.family: Style.font.family
                        font.pixelSize: Style.font.heading
                        font.bold: true
                    }

                    Text {
                        Layout.fillWidth: true
                        text: !bridge.connected ? "Connecting…" : bridge.cancellingRun ? (bridge.cancelAccepted ? "Stopping…" : "Requesting stop…") : root.busy ? "Working…" : "Desktop conversation"
                        color: Color.popups.text
                        opacity: 0.65
                        font.pixelSize: Style.font.body
                    }

                    Button {
                        text: "New"
                        enabled: bridge.connected && !root.busy && bridge.status && bridge.status.phase === "idle"
                        onClicked: bridge.reset()
                    }

                    Button {
                        text: "Close"
                        onClicked: root.close()
                    }

                }

                ListView {
                    id: history

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: Style.space(16)
                    model: root.rows
                    onModelChanged: Qt.callLater(function() {
                        history.positionViewAtEnd();
                    })

                    Text {
                        anchors.centerIn: parent
                        visible: history.count === 0
                        text: "Message Noemir from your desktop."
                        color: Color.popups.text
                        opacity: 0.65
                        font.pixelSize: Style.font.body
                    }

                    ScrollBar.vertical: ScrollBar {
                    }

                    delegate: Column {
                        required property var modelData

                        width: history.width - Style.space(12)
                        spacing: Style.space(4)

                        Text {
                            text: modelData.role === "user" ? "You" : "Noemir"
                            color: modelData.role === "user" ? Color.accent : Color.popups.text
                            font.family: Style.font.family
                            font.pixelSize: Style.font.body
                            font.bold: true
                        }

                        TextEdit {
                            width: parent.width
                            text: modelData.text
                            textFormat: TextEdit.PlainText
                            readOnly: true
                            selectByMouse: true
                            wrapMode: TextEdit.Wrap
                            color: Color.popups.text
                            font.family: Style.font.family
                            font.pixelSize: Style.font.body
                        }

                        Text {
                            visible: ["failed", "cancelled", "interrupted"].indexOf(modelData.status) >= 0
                            text: modelData.status
                            color: Color.urgent
                            font.pixelSize: Style.font.body
                        }

                    }

                }

                Text {
                    Layout.fillWidth: true
                    visible: bridge.error !== ""
                    text: bridge.error
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                    color: Color.urgent
                    font.pixelSize: Style.font.body
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Style.space(100)

                    TextArea {
                        id: editor

                        text: root.draft
                        onTextChanged: root.draft = text
                        placeholderText: "Message Noemir…"
                        wrapMode: TextEdit.Wrap
                        selectByMouse: true
                        color: Color.popups.text
                        font.family: Style.font.family
                        font.pixelSize: Style.font.body
                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Escape) {
                                root.close();
                                event.accepted = true;
                            } else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && !(event.modifiers & Qt.ShiftModifier)) {
                                if (!root.busy)
                                    bridge.send(root.draft);

                                event.accepted = true;
                            }
                        }

                        background: Rectangle {
                            color: "transparent"
                            radius: Style.cornerRadius
                            border.color: editor.activeFocus ? Color.accent : Color.popups.border
                            border.width: 1
                        }

                    }

                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: "Enter to send · Shift+Enter for newline · Esc to close"
                        color: Color.popups.text
                        opacity: 0.65
                        font.pixelSize: Style.font.body
                    }

                    Button {
                        visible: !!(bridge.conversation && bridge.conversation.active_run)
                        text: "Stop"
                        enabled: bridge.connected && bridge.cancellingRun !== bridge.conversation.active_run
                        onClicked: bridge.cancel()
                    }

                    Button {
                        text: "Send"
                        enabled: bridge.connected && !root.busy && root.draft.trim() !== ""
                        onClicked: bridge.send(root.draft)
                    }

                }

            }

        }

    }

}
