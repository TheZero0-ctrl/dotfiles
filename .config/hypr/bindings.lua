-- Omarchy Cleaner: disable removed apps before personal overrides.
hl.unbind("SUPER + SHIFT + A")
hl.unbind("SUPER + SHIFT + ALT + A")
hl.unbind("SUPER + SHIFT + ALT + E")
hl.unbind("SUPER + SHIFT + ALT + G")
hl.unbind("SUPER + SHIFT + ALT + X")
hl.unbind("SUPER + SHIFT + C")
hl.unbind("SUPER + SHIFT + CTRL + G")
hl.unbind("SUPER + SHIFT + E")
hl.unbind("SUPER + SHIFT + P")
hl.unbind("SUPER + SHIFT + S")
hl.unbind("SUPER + SHIFT + W")
hl.unbind("SUPER + SHIFT + X")
hl.unbind("SUPER + SHIFT + Y")

-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

local noemir_desktop = "/home/ankit/.local/bin/noemir desktop --server-url http://127.0.0.1:7437 --no-start"
local function noemir_with_overlay(action)
  return "sh -lc \"omarchy-shell shell summon io.noemir.desktop '{}' >/dev/null && exec " .. noemir_desktop .. " " .. action .. "\""
end
o.bind("SUPER + SHIFT + V", "Noemir voice", noemir_with_overlay("listen"), { dont_inhibit = true })
o.bind("F9", "Noemir push-to-talk", noemir_with_overlay("ptt-start"), { dont_inhibit = true })
o.bind("F9", "Finish Noemir push-to-talk", noemir_desktop .. " ptt-stop", { release = true, dont_inhibit = true })
o.bind("SUPER + N", "Noemir quick text", "omarchy-shell shell toggle io.noemir.desktop '{\"mode\":\"text\"}'")
