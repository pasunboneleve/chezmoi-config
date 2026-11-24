# Shell configuration

Chezmoi manages Bash, Zsh, Starship, direnv, Ghostty, GHCi, Karabiner, and
xremap directly. On upgrade, it replaces the symlinks to the previous
`~/.config/dotfiles` checkout with regular files. The old checkout can be
archived independently. For `sync-github-favourites`, move your list to
`~/.config/github-favourites/github-favourites.txt` or pass the list path as
an argument.

## Shell-only setup on Ubuntu WorkSpaces

Ubuntu 24.04 LTS ships Emacs 29.3. If the workstation already has Bash and
chezmoi, apply the shell files and install the optional tools from this
repository without sudo.

```sh
chezmoi --source . --override-data '{"skipEmacsConfig":true}' apply --parent-dirs \
  "$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.zprofile" "$HOME/.zshenv" "$HOME/.zshrc" \
  "$HOME/.config/shell" "$HOME/.config/starship.toml" "$HOME/.config/direnv/direnvrc"
bash ./run_after_19-install-shell-tools.sh
```

The tool installer downloads missing executables to `~/.local/bin`. Bash and
Zsh retain their built-in prompt, completion, and history when optional tools
are unavailable. The shell-only apply leaves the workstation’s login shell
and Emacs installation in place.

## Interactive use

- Press Tab for Carapace completions. On macOS, use Homebrew Bash for Carapace
  in Bash. The system Bash 3.2 uses its existing completion support.
- Press Ctrl-R for Atuin. Run `atuin import auto` once from each shell whose
  existing history you want to import. Up and Down search native history by
  prefix. Atuin stores history locally by default.
- Use `z` or `zi` for navigation with zoxide.
- Starship retains directory, Git, Kubernetes, Python, Haskell, time, and
  duration information. The Haskell compiler module checks the active GHC
  directly. Run `CHEZMOI_PROMPT=native zsh` or `CHEZMOI_PROMPT=native bash`
  for the built-in prompt.
- `TERM=dumb` uses a plain prompt for Emacs TRAMP and skips interactive tools.
  Keep local environment secrets in `~/.secret_env`.

## Smoke test

Run `bash tests/shell-smoke.sh` on Fedora, macOS, or Ubuntu with Bash, Zsh,
and chezmoi installed. Use `--install-tools` to also download and exercise
the actual shell integrations inside the temporary home directory.
