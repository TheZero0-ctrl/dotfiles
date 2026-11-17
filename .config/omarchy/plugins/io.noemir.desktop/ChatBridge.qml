import QtQuick
import Quickshell.Io

Item {
    id: root

    property bool active: false
    property string binary: "noemir"
    property string home: ""
    property string serverUrl: ""
    property bool connected: false
    property bool sending: false
    property var pendingSend: null
    property var pendingReset: null
    property bool resetting: false
    property string cancellingRun: ""
    property bool cancelAccepted: false
    readonly property string connectionKey: JSON.stringify([binary, home, serverUrl])
    property string processConnection: ""
    property var conversation: null
    property var run: null
    property var status: null
    property string commandError: ""
    property string pollWarning: ""
    property string streamWarning: ""
    property string streamWarningRun: ""
    readonly property string error: commandError || (run && run.error ? run.error : "") || streamWarning || pollWarning
    readonly property bool pollError: pollWarning !== ""
    property int retryDelay: 250

    signal accepted(string content)

    function clearCancellation() {
        cancellingRun = "";
        cancelAccepted = false;
    }

    function recoverObservation(operation, runId) {
        if (operation === "poll")
            pollWarning = "";
        if (operation === "stream" && streamWarningRun === runId) {
            streamWarning = "";
            streamWarningRun = "";
        }
    }

    function adoptRun(snapshot, fromStream) {
        if (conversation && snapshot.conversation_id !== conversation.id)
            return;
        if (conversation && conversation.active_run && snapshot.id !== conversation.active_run)
            return;
        if (run && run.id === snapshot.id && snapshot.revision < run.revision)
            return;
        run = snapshot;
        if (fromStream || ["completed", "failed", "cancelled", "interrupted"].indexOf(snapshot.status) >= 0)
            recoverObservation("stream", snapshot.id);
        if (snapshot.id === cancellingRun && ["completed", "failed", "cancelled", "interrupted"].indexOf(snapshot.status) >= 0)
            clearCancellation();
    }

    function uuid() {
        return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function(c) {
            var r = Math.floor(Math.random() * 16);
            return (c === "x" ? r : (r & 3) | 8).toString(16);
        });
    }

    function selectConnection() {
        if (processConnection !== connectionKey) {
            // Pending commands belong to the selected service, not the panel.
            // Keep the editor's draft, but never replay into a different home.
            pendingSend = null;
            sending = false;
            pendingReset = null;
            resetting = false;
            clearCancellation();
            pollWarning = "";
            streamWarning = "";
            streamWarningRun = "";
            conversation = null;
            run = null;
            status = null;
        }
        processConnection = connectionKey;
    }

    function start() {
        if (!active || process.running)
            return ;
        selectConnection();

        var command = [binary];
        if (home)
            command.push("--home", home);

        command.push("desktop", "--no-start");
        if (serverUrl)
            command.push("--server-url", serverUrl);

        command.push("connect", "--json");
        process.command = command;
        process.running = true;
    }

    function write(value) {
        if (connected) {
            value.version = 1;
            process.write(JSON.stringify(value) + "\n");
        }

    }

    function send(text) {
        if (!connected || sending || !text.trim())
            return ;

        if (!pendingSend || pendingSend.content !== text)
            pendingSend = {
            "type": "send",
            "request_id": uuid(),
            "content": text
        };

        commandError = "";
        sending = true;
        write(pendingSend);
    }

    function cancel() {
        var id = conversation ? conversation.active_run : null;
        if (id && connected && cancellingRun !== id) {
            cancellingRun = id;
            cancelAccepted = false;
            write({
            "type": "cancel",
            "run_id": id
        });
        }

    }

    function reset() {
        if (!connected || resetting)
            return;
        commandError = "";
        if (!pendingReset)
            pendingReset = {type: "reset", request_id: uuid()};
        resetting = true;
        write(pendingReset);
    }

    function receive(line) {
        if (processConnection !== connectionKey)
            return;

        var event;
        try {
            event = JSON.parse(line);
        } catch (e) {
            commandError = "Invalid response from Noemir";
            return ;
        }
        if (event.version !== 1)
            return ;

        if (event.type === "ready") {
            connected = true;
            retryDelay = 250;
            commandError = "";
            recoverObservation("poll", null);
            // A send interrupted before acknowledgement uses its original ID.
            if (pendingSend && sending)
                write(pendingSend);
            if (pendingReset && resetting)
                write(pendingReset);
            if (cancellingRun && conversation && conversation.active_run === cancellingRun)
                write({type: "cancel", run_id: cancellingRun});

        } else if (event.type === "history") {
            recoverObservation("poll", null);
            if (!conversation || conversation.id !== event.conversation.id
                    || (event.conversation.active_run && run && run.id !== event.conversation.active_run))
                run = null;

            // Periodic refreshes should not rebuild unchanged history and reset
            // the panel's scroll position while the owner is reading.
            if (!conversation || JSON.stringify(conversation) !== JSON.stringify(event.conversation))
                conversation = event.conversation;
            if (cancellingRun && conversation.active_run !== cancellingRun) {
                clearCancellation();
            }
            if (streamWarningRun && conversation.active_run !== streamWarningRun)
                recoverObservation("stream", streamWarningRun);
        } else if (event.type === "status") {
            recoverObservation("poll", null);
            status = event.status;
        } else if (event.type === "run") {
            adoptRun(event.run, true);
        } else if (event.type === "accepted") {
            if (pendingSend && pendingSend.request_id === event.request_id) {
                var text = pendingSend.content;
                pendingSend = null;
                sending = false;
                accepted(text);
            }
            if (conversation)
                adoptRun(event.run, false);
        } else if (event.type === "recovered") {
            recoverObservation(event.operation, event.run_id);
        } else if (event.type === "cancel_requested") {
            // Admission acknowledgment is distinct from the eventual run state.
            if (event.run_id === cancellingRun) {
                cancelAccepted = true;
                commandError = "";
            }
        } else if (event.type === "reset") {
            if (pendingReset && pendingReset.request_id === event.request_id) {
                pendingReset = null;
                resetting = false;
            }
        } else if (event.type === "error") {
            if (event.operation === "cancel" && event.run_id !== cancellingRun)
                return;
            if (event.operation === "send" && (!pendingSend || event.request_id !== pendingSend.request_id))
                return;
            if (event.operation === "reset" && (!pendingReset || event.request_id !== pendingReset.request_id))
                return;
            if (event.operation === "poll")
                pollWarning = event.error;
            else if (event.operation === "stream") {
                if (!conversation || conversation.active_run === event.run_id) {
                    streamWarning = event.error;
                    streamWarningRun = event.run_id;
                }
            } else
                commandError = event.error;
            if (!event.operation) {
                sending = false;
                resetting = false;
            } else {
                if ((event.operation === "send" || event.operation === "command") && pendingSend && pendingSend.request_id === event.request_id)
                    sending = false;
                if ((event.operation === "reset" || event.operation === "command") && pendingReset && pendingReset.request_id === event.request_id)
                    resetting = false;
                if (event.operation === "cancel" && event.run_id === cancellingRun) {
                    clearCancellation();
                }
            }
        }
    }

    onActiveChanged: {
        retry.stop();
        connected = false;
        if (active)
            start();
        else
            process.running = false;
    }

    Process {
        id: process

        stdinEnabled: true
        onExited: {
            root.connected = false;
            if (root.active) {
                if (!root.error)
                    root.commandError = "Disconnected from Noemir. Reconnecting…";

                retry.interval = root.retryDelay;
                root.retryDelay = Math.min(root.retryDelay * 2, 10000);
                retry.restart();
            }
        }

        stdout: SplitParser {
            onRead: function(line) {
                root.receive(line);
            }
        }

        stderr: SplitParser {
            onRead: function(line) {
                if (line.trim())
                    root.commandError = line;

            }
        }

    }

    Timer {
        id: retry

        onTriggered: root.start()
    }

}
