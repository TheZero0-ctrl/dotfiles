import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string runtimeDir: Quickshell.env("XDG_RUNTIME_DIR")
    readonly property string socketPath: runtimeDir ? runtimeDir + "/noemir/desktop-status.sock" : ""
    readonly property var states: ["starting", "idle", "listening", "transcribing", "thinking", "speaking", "delivering_check_in", "check_in_pending", "error"]
    property var record: null
    property int retryDelay: 250
    readonly property bool backgroundThinking: record !== null && record.background_thinking === true

    width: 0
    height: 0
    visible: false

    function isInteger(value) {
        return typeof value === "number" && isFinite(value) && Math.floor(value) === value;
    }

    function validRecord(value) {
        if (!value || typeof value !== "object" || Array.isArray(value))
            return false;

        var allowed = ["version", "revision", "state", "mode", "notice", "background_thinking"];
        var keys = Object.keys(value);
        if (keys.length !== allowed.length)
            return false;

        for (var i = 0; i < keys.length; i++) {
            if (allowed.indexOf(keys[i]) < 0)
                return false;
        }
        if (!isInteger(value.version) || value.version !== 1)
            return false;

        if (!isInteger(value.revision) || value.revision < 0 || value.revision > Math.pow(2, 64) - 1)
            return false;

        if (states.indexOf(value.state) < 0)
            return false;

        if (value.mode !== null && value.mode !== "tap" && value.mode !== "push_to_talk")
            return false;

        if (value.notice !== null && value.notice !== "busy")
            return false;

        return typeof value.background_thinking === "boolean";
    }

    function parse(line) {
        var parsed;
        try {
            parsed = JSON.parse(String(line || ""));
        } catch (e) {
            return;
        }
        if (validRecord(parsed))
            record = parsed;
    }

    function reconnect() {
        if (!socketPath)
            return;

        retryDelay = 250;
        socketLoader.active = false;
        reconnectTimer.interval = 1;
        reconnectTimer.restart();
    }

    function scheduleReconnect() {
        if (!socketPath || reconnectTimer.running)
            return;

        socketLoader.active = false;
        reconnectTimer.interval = retryDelay;
        retryDelay = Math.min(retryDelay * 2, 10000);
        reconnectTimer.start();
    }

    Component {
        id: socketComponent

        Socket {
            path: root.socketPath
            connected: true
            parser: SplitParser {
                onRead: function(line) {
                    root.parse(line);
                }
            }
            onConnectionStateChanged: {
                if (connected) {
                    root.retryDelay = 250;
                    reconnectTimer.stop();
                } else {
                    root.record = null;
                    root.scheduleReconnect();
                }
            }
            onError: {
                root.record = null;
                root.scheduleReconnect();
            }
        }
    }

    Loader {
        id: socketLoader

        active: root.socketPath !== ""
        sourceComponent: socketComponent
    }

    Timer {
        id: reconnectTimer

        onTriggered: {
            socketLoader.active = true;
        }
    }

    Component.onCompleted: socketLoader.active = true
}
