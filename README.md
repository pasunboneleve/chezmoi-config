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
CHEZMOI_INSTALL_PACKAGES=1 chezmoi --source . apply
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
CHEZMOI_SKIP_EMACS_CONFIG=1 chezmoi --source . apply
```

Installer helper usage is documented in
[docs/development/install-package-helpers.md](docs/development/install-package-helpers.md).
External dotfile checkout ownership is documented in
[docs/development/external-dotfiles.md](docs/development/external-dotfiles.md).

On Fedora, `dnf` installs the zsh plugins it packages
(`zsh-autosuggestions` and `zsh-syntax-highlighting`). The install script
clones `zsh-autocomplete`, `zsh-completions`, `zsh-history-substring-search`,
and `zsh-z` into `~/.local/share/zsh/plugins` because those are not available
from the enabled Fedora repos on this machine. On macOS, Homebrew installs the
packaged zsh plugins directly.

The Codex CLI is installed from a Sigstore-verified GitHub release on Linux
(`install-codex-latest`). Codex publishes Sigstore bundles only for its Linux
musl targets, so on macOS Codex is installed from the `codex` Homebrew cask
instead, and `install-codex-latest` is not run.

## Managed Highlights

- `~/.config/dotfiles` from `github.com/pasunboneleve/dotfiles`
- `~/.zshrc` and `~/.zshenv`, symlinked into `~/.config/dotfiles`
- default login shell set to `zsh`
- `~/.gitconfig`
- `~/.codex/config.toml`, with required Codex defaults and MCP server entries preserved without duplication
- `~/.config/ghostty/config`, symlinked into `~/.config/dotfiles`
- `~/.config/karabiner/karabiner.json`, symlinked into `~/.config/dotfiles`
- `~/.config/starship.toml`, symlinked into `~/.config/dotfiles`
- `~/.ghci`, symlinked into `~/.config/dotfiles`
- `~/.config/direnv/direnvrc`, symlinked into `~/.config/dotfiles`
- `~/.config/emacs` from `github.com/pasunboneleve/emacs.d`
- `~/.roborev/config.toml`, with `server_addr` enforced as `unix://`
- Linux-only `~/.config/xremap/xremap.yml`, symlinked into `~/.config/dotfiles`
- Linux-only user services:
  - `emacs.service`
  - `kata.service`
  - `roborev.service`
  - `sync-gtk-theme-to-gnome.service`
  - `xremap.service`
  These are enabled idempotently on every `chezmoi apply`.
- Linux-only Emacs client desktop entry
- macOS-only Karabiner config, symlinked into `~/.config/dotfiles`, reproducing
  the laptop-keyboard home-row mods (hold `a`/`;` = Command, `s`/`l` = Shift,
  `d`/`k` = Option, `f`/`j` = Control). Spotlight is reached the same way as on
  the Moonlander: hold `a` briefly, then press Space. The home-row remaps
  exclude the Moonlander itself. Requires the `karabiner-elements` cask.

## Notes

Secrets are intentionally not managed here. Keep machine-local values in
`~/.secret_env`.
