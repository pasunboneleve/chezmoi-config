# External Dotfiles

`~/.config/dotfiles` is an external checkout of
`git@github.com:pasunboneleve/dotfiles.git`.

Chezmoi owns the checkout and the symlinks from standard config locations into
that checkout. It does not own copies of the dotfiles payloads. Put changes to
the shared shell, prompt, terminal, Karabiner, xremap, direnv, and GHCi files
in the dotfiles repository, then update symlink descriptors here only when a
new target path needs to point into that checkout.

Current symlinked targets:

- `~/.zshenv` -> `~/.config/dotfiles/zshenv`
- `~/.zshrc` -> `~/.config/dotfiles/zshrc`
- `~/.ghci` -> `~/.config/dotfiles/ghci`
- `~/.config/starship.toml` -> `~/.config/dotfiles/starship.toml`
- `~/.config/ghostty/config` -> `~/.config/dotfiles/ghostty`
- `~/.config/karabiner/karabiner.json` -> `~/.config/dotfiles/karabiner.json`
- `~/.config/direnv/direnvrc` -> `~/.config/dotfiles/direnvrc`
- `~/.config/xremap/xremap.yml` -> `~/.config/dotfiles/xremap.yml`

The xremap config target is Linux-only because xremap is ignored on other
operating systems. The `xremap.service` unit itself is managed by this chezmoi
source, not by the external dotfiles checkout, because new-machine bootstrap
must install user units before enabling them.

If `xremap.service` starts but cannot read its config, make sure
`~/.config/dotfiles` was cloned successfully and contains `xremap.yml`, then run
`chezmoi apply` again.

The `z` command comes from the `zsh-z` plugin. It is not a dotfiles payload, so
there is no symlink target for it here. The package installer clones
`zsh-z` into `~/.local/share/zsh/plugins` when the operating-system package
branch does not install it directly.
