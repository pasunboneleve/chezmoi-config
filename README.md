# Chezmoi Config

Personal machine configuration managed by chezmoi.

## Bootstrap

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:pasunboneleve/chezmoi-config.git
```

If chezmoi is already installed:

```sh
chezmoi init --apply git@github.com:pasunboneleve/chezmoi-config.git
```

Package installation is opt-in:

```sh
CHEZMOI_INSTALL_PACKAGES=1 chezmoi apply
```

On Fedora, `dnf` installs the zsh plugins it packages
(`zsh-autosuggestions` and `zsh-syntax-highlighting`). The install script
clones `zsh-autocomplete`, `zsh-completions`, `zsh-history-substring-search`,
and `zsh-z` into `~/.local/share/zsh/plugins` because those are not available
from the enabled Fedora repos on this machine. On macOS, Homebrew installs the
packaged zsh plugins directly.

## Managed Highlights

- `~/.zshrc`
- `~/.zshenv`
- `~/.gitconfig`
- `~/.config/ghostty/config`
- `~/.config/starship.toml`
- `~/.config/emacs` from `github.com/pasunboneleve/emacs.d`
- Linux-only `~/.config/xremap/xremap.yml`
- Linux-only Emacs desktop entries

## Notes

Secrets are intentionally not managed here. Keep machine-local values in
`~/.secret_env`.
