# Linux Keyboard Layout

Linux [GNOME](https://www.gnome.org/) machines get a user [XKB](https://xkbcommon.org/) overlay under [`dot_config/xkb/`](../../dot_config/xkb/). [chezmoi](https://www.chezmoi.io/) writes that overlay to `~/.config/xkb`. macOS ignores those files.

The overlay adds layout `brctrl`: Portuguese (Brazil) ABNT2, except Control on the Brazilian semicolon key (`<AB10>`) emits `C-/`. Australian `au` is unchanged, so `C-;` stays `C-;` there.

[`dot_local/bin/executable_configure-keyboard-layout`](../../dot_local/bin/executable_configure-keyboard-layout) runs from [`run_after_50-user-services-linux.sh.tmpl`](../../run_after_50-user-services-linux.sh.tmpl) on GNOME. It requires the overlay file, then sets:

- input sources `au` and `brctrl`
- `lv3:ralt_alt`, so Right Alt is Meta rather than AltGr
- `model:applealu_ansi` as well, when an Apple Aluminum ANSI keyboard is on USB

Switch sources with Super+Space. If `brctrl` was added while the session was already running, log out and back in so GNOME Shell picks up `~/.config/xkb`.
