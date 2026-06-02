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

## Managed Highlights

- `~/.config/dotfiles` from `github.com/pasunboneleve/dotfiles`
- `~/.zshrc` and `~/.zshenv`, symlinked into `~/.config/dotfiles`
- `~/.gitconfig`
- `~/.config/ghostty/config`, symlinked into `~/.config/dotfiles`
- `~/.config/starship.toml`, symlinked into `~/.config/dotfiles`
- `~/.ghci`, symlinked into `~/.config/dotfiles`
- `~/.config/direnv/direnvrc`, symlinked into `~/.config/dotfiles`
- `~/.config/emacs` from `github.com/pasunboneleve/emacs.d`
- Linux-only `~/.config/xremap/xremap.yml`, symlinked into `~/.config/dotfiles`
- Linux-only user services:
  - `emacs.service`
  - `sync-gtk-theme-to-gnome.service`
  - `xremap.service`, symlinked into `~/.config/dotfiles`
  These are enabled idempotently on every `chezmoi apply`.
- Linux-only Emacs client desktop entry

## Notes

Secrets are intentionally not managed here. Keep machine-local values in
`~/.secret_env`.
