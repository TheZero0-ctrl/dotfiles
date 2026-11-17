# Noemir Desktop Status

A standalone Omarchy 4.x shell plugin that renders Noemir voice activity as a
small bottom-center Wayland overlay and background evaluations in the status
bar. The overlay is visual only: it takes no keyboard focus, has an empty input
region, and does not reserve screen space.

This repository only defines the desktop status consumer and its protocol. The
Noemir service is the producer; neither repository depends on the other's
internal implementation.

## Protocol

The plugin connects to `$XDG_RUNTIME_DIR/noemir/desktop-status.sock`. The service
sends the current state immediately after connection and then sends one complete
newline-delimited JSON snapshot whenever state changes. Indicators clear on
disconnect and reconnect with bounded backoff.

Protocol v1 is a JSON object with exactly these public fields:

| Field | Type | Values |
| --- | --- | --- |
| `version` | `u32` | `1` |
| `revision` | `u64` | Monotonically increasing writer revision |
| `state` | string | `starting`, `idle`, `listening`, `transcribing`, `thinking`, `speaking`, or `error` |
| `mode` | string or null | `tap`, `push_to_talk`, or `null` |
| `notice` | string or null | `busy` or `null` |
| `background_thinking` | boolean | Whether a background evaluation is active |

Transcript and response text are deliberately excluded. A new revision with a
`busy` notice briefly acknowledges the event without replacing the current
state.

Example:

```json
{
  "version": 1,
  "revision": 42,
  "state": "listening",
  "mode": "push_to_talk",
  "notice": null,
  "background_thinking": true
}
```

## Local install

From this repository, create a development symlink and ask the running shell to
discover it:

```bash
mkdir -p "$HOME/.config/omarchy/plugins"
ln -s "$PWD" "$HOME/.config/omarchy/plugins/io.noemir.desktop"
omarchy-shell shell rescanPlugins
omarchy plugin enable io.noemir.desktop
omarchy-shell shell summon io.noemir.desktop '{}'
```

If it was already enabled, `omarchy-shell shell rescanPlugins` is sufficient
after changing plugin files. The panel must be summoned once per shell session
so its file watcher is loaded. For automatic startup, add this to
`~/.config/hypr/autostart.lua`:

```lua
o.exec_on_start("omarchy-shell shell summon io.noemir.desktop '{}'")
```

Remove the symlink to uninstall the local copy.

Validate the manifest before enabling it:

```bash
omarchy plugin validate .
```

## Fixture testing

The fixture helper starts a local socket server. Stop Noemir before using it,
because the production service owns the same private socket:

```bash
scripts/show-fixture listening
scripts/show-fixture transcribing
scripts/show-fixture thinking
scripts/show-fixture speaking
scripts/show-fixture error
scripts/show-fixture busy
scripts/show-fixture background
scripts/show-fixture idle
scripts/show-fixture clear
```

The helper requires `jq` and `socat`. `clear` stops the fixture server. It only
writes beneath `$XDG_RUNTIME_DIR/noemir`; it does not alter Omarchy
configuration.

## License

MIT
