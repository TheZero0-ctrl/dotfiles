-- Extra autostart processes.
-- o.launch_on_start("my-service")

o.exec_on_start("sh -lc 'i=0; until [ -S \"$XDG_RUNTIME_DIR/noemir/desktop-status.sock\" ] && omarchy-shell shell summon io.noemir.desktop \"{}\"; do i=$((i+1)); [ \"$i\" -ge 60 ] && exit 1; sleep 1; done'")
