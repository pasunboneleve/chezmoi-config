# Linux Keyboard Layout

Linux [GNOME](https://www.gnome.org/) machines get a user [XKB](https://xkbcommon.org/) overlay under [`dot_config/xkb/`](../../dot_config/xkb/). [chezmoi](https://www.chezmoi.io/) writes that overlay to `~/.config/xkb`. macOS ignores those files.

The overlay adds layout `brctrl`: Portuguese (Brazil) ABNT2 with programming
punctuation on convenient keys:

- the physical Brazilian semicolon key (`<AB10>`) emits `/`, or `?` with Shift;
- the `ç` key emits `;` with Left Alt and `:` with Left Alt+Shift;
- the dead `~` key emits `"` with Left Alt and `'` with Left Alt+Shift.

The extra punctuation uses the standard XKB AltGr levels. In `brctrl`, Left Alt
selects AltGr for ergonomic opposite-hand chords, while Right Alt remains Meta.
With the managed home-row modifiers, `d` selects punctuation and `k` remains
Meta. The punctuation is inserted as text in applications such as Chromium and
Emacs. All inherited Brazilian third- and fourth-level symbols are disabled, so
Left Alt only changes the `ç` and dead `~` keys. Control remains visible to
applications, so Control on the physical semicolon key emits `C-/`. Australian
`au` is unchanged, including both Alt keys, so `C-;` stays `C-;` there.

[`dot_local/bin/executable_configure-keyboard-layout`](../../dot_local/bin/executable_configure-keyboard-layout) runs from [`run_after_50-user-services-linux.sh.tmpl`](../../run_after_50-user-services-linux.sh.tmpl) on GNOME. It requires the overlay file, then sets:

- input sources `au` and `brctrl`
- `model:applealu_ansi` as well, when an Apple Aluminum ANSI keyboard is on USB

Switch sources with Super+Space. If `brctrl` was added while the session was already running, log out and back in so GNOME Shell picks up `~/.config/xkb`.
