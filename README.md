# Chezmoi Config

Personal machine configuration managed by chezmoi.

## Bootstrap

Run chezmoi from this repository and pass the source directory explicitly;
otherwise chezmoi uses its default source directory.

```sh
git clone git@github.com:pasunboneleve/chezmoi-config.git
cd chezmoi-config
chezmoi --source . apply
```

If the source repository already exists:

```sh
chezmoi --source . apply
```

Package installation is opt-in:

```sh
chezmoi --source . --override-data '{"installPackages":true}' apply
```

Normal `chezmoi --source . apply` also runs userland tool installers for tools
that do not need system package-manager privileges, including Rust, Node,
language CLIs, and AI/developer CLIs.

On Fedora, package installation includes `zsh`. When `zsh` is installed,
chezmoi changes the account's default shell to `zsh`. Start a new login session
after the first successful shell change.

Agent or service users that cannot access the private Emacs config repository
can skip that external checkout and the Emacs batch setup:

```sh
chezmoi --source . --override-data '{"installPackages":true,"skipEmacsConfig":true}' apply
```

Installer helper usage is documented in
[docs/development/install-package-helpers.md](docs/development/install-package-helpers.md).
Linux GNOME keyboard sources and the Brazilian punctuation overlay are
documented in
[docs/development/linux-keyboard-layout.md](docs/development/linux-keyboard-layout.md).
After applying this configuration, run `chezmoi-options` to display the
available bootstrap options and copyable commands.

Zsh and Bash share environment settings and use Carapace for Tab completion,
Atuin for Ctrl-R history search, zoxide for directory jumping, and Starship
for the prompt. Set `CHEZMOI_PROMPT=native` to start with the built-in prompt.
See [shell setup and migration](docs/development/shell-configuration.md) for
the no-sudo Ubuntu WorkSpaces setup, history import, and smoke tests.

On Linux, `install-codex-latest` verifies the complete Codex release package
against its published digests, verifies its signed executables with Sigstore,
and installs its helper executables and bundled resources. On macOS, the
`codex` Homebrew cask installs the CLI instead, and `install-codex-latest` is
not run. The system package hook also installs the Codex desktop app from
OpenAI's latest `chatgpt` RPM on Fedora and the `chatgpt` cask on macOS.

## Managed Highlights

- `~/.zprofile`, `~/.zshrc`, `~/.zshenv`, `~/.bashrc`, and `~/.bash_profile` managed directly here
- `~/.config/shell` for shared shell settings, functions, and the Markdown template
- Fedora default login shell set to `zsh`
- `~/.gitconfig`
- `~/.codex/config.toml`, with required Codex defaults and MCP server entries preserved without duplication
- `~/.config/ghostty/config`
- `~/.config/starship.toml`
- `~/.ghci`
- `~/.config/direnv/direnvrc`
- `~/.config/emacs` from `github.com/pasunboneleve/emacs.d`
- `~/.roborev/config.toml`, with `server_addr` enforced as `unix://`
- Linux-only `~/.config/xremap/xremap.yml`
- Linux-only `~/.config/xkb` overlay (`brctrl`) and GNOME sources `au` plus `brctrl`
- Linux-only user services:
  - `emacs.service`
  - `kata.service`
  - `roborev.service`
  - `sync-gtk-theme-to-gnome.service`
  - `xremap.service`
  These are enabled idempotently on every `chezmoi apply`.
- Linux-only Emacs client desktop entry
- macOS-only `~/.config/karabiner/karabiner.json`, reproducing the
  laptop-keyboard home-row mods (hold `a`/`;` = Command,
  `s`/`l` = Shift, `d`/`k` = Option, `f`/`j` = Control). Spotlight is reached
  the same way as on the Moonlander: hold `a` briefly, then press Space. The
  home-row remaps exclude the Moonlander itself. Requires the
  `karabiner-elements` cask.

## Notes

Keep machine-local secrets in `~/.secret_env`. Normal interactive shells
load this file.
