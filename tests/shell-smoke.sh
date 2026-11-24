#!/usr/bin/env bash
set -euo pipefail

source_dir="$(cd "$(dirname "$0")/.." && pwd -P)"
work="$(mktemp -d "${TMPDIR:-/tmp}/chezmoi-shell-test.XXXXXXXX")"
trap 'rm -rf "$work"' EXIT

bash_bin="$(command -v bash)"
zsh_bin="$(command -v zsh)"
export HOME="$work/home" ZDOTDIR="$work/home"
unset BASH_ENV ENV XDG_CONFIG_HOME XDG_DATA_HOME STARSHIP_CONFIG DENO_INSTALL KREW_ROOT
mkdir -p "$HOME/.config/dotfiles" "$HOME/.config/direnv" "$HOME/.bashrc.d"
touch "$work/chezmoi.toml"

# Reproduce a home directory managed by the previous source.
for old_file in zprofile zshenv zshrc; do
  printf '# previous checkout\n' > "$HOME/.config/dotfiles/$old_file"
  ln -s ".config/dotfiles/$old_file" "$HOME/.$old_file"
done
printf '# previous direnv configuration\n' > "$HOME/.config/dotfiles/direnvrc"
ln -s ../dotfiles/direnvrc "$HOME/.config/direnv/direnvrc"
printf '# previous prompt\n' > "$HOME/.config/dotfiles/starship.toml"
ln -s dotfiles/starship.toml "$HOME/.config/starship.toml"
cat > "$HOME/.profile" <<'PROFILE'
. "$HOME/.bashrc"
export PATH="$HOME/.local/bin:$PATH"
PROFILE
printf '%s\n' 'local_rc_count=$((${local_rc_count:-0} + 1))' > "$HOME/.bashrc.d/test.sh"
printf '%s\n' 'shell_test_secret=loaded' > "$HOME/.secret_env"

apply_shell() {
  chezmoi --config "$work/chezmoi.toml" --source "$source_dir" --destination "$HOME" \
    --cache "$work/cache" --persistent-state "$work/state" --refresh-externals=never \
    --override-data '{"skipEmacsConfig":true}' --no-tty apply --parent-dirs "$@" \
    "$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.zprofile" "$HOME/.zshenv" "$HOME/.zshrc" \
    "$HOME/.config/shell" "$HOME/.config/starship.toml" "$HOME/.config/direnv/direnvrc"
}

assert_shell() {
  local term="$1" shell="$2" flags="$3" assertions="$4" output
  if ! output="$(TERM="$term" "$shell" "$flags" "$assertions" 2>&1)"; then
    printf '%s %s TERM=%s failed:\n%s\n' "$shell" "$flags" "$term" "$output" >&2
    return 1
  fi
  if [[ "$output" == *"command not found"* || "$output" == *"syntax error"* ]]; then
    printf '%s\n' "$output" >&2
    return 1
  fi
}

# Apply twice to check that the symlink migration is idempotent.
apply_shell --force
apply_shell --error-on-conflict
for file in .zprofile .zshenv .zshrc .config/starship.toml .config/direnv/direnvrc; do
  [[ -f "$HOME/$file" && ! -L "$HOME/$file" ]]
done
[[ "$(cat "$HOME/.config/dotfiles/zshrc")" == '# previous checkout' ]]

shared_environment='
  case ":$PATH:" in *:"$HOME/.local/bin":*:"$HOME/.local/bin":*) exit 1;; esac
  case ":$PATH:" in *:"$HOME/.local/bin":*) ;; *) exit 1;; esac
  [ "$EDITOR" = "emacsclient -t" ] && [ "$GOBIN" = "$HOME/go/bin" ]
'
plain_shell='[ -z "${shell_test_secret:-}" ] && ! command -v render-markdown >/dev/null'
interactive_shell='
  [ "$shell_test_secret" = loaded ] &&
    command -v gcloud-use >/dev/null && command -v render-markdown >/dev/null
'

unset EDITOR VISUAL GOBIN GOPATH NVM_DIR
export CHEZMOI_PROMPT=native
assert_shell xterm "$bash_bin" -lc "{ $shared_environment } && $plain_shell"
assert_shell xterm "$zsh_bin" -c "{ $shared_environment } && $plain_shell"
for shell in "$bash_bin" "$zsh_bin"; do
  assert_shell dumb "$shell" -ilc "[ \"\$PS1\" = '\$ ' ] && $plain_shell"
  assert_shell xterm "$shell" -ilc "{ $shared_environment } && { $interactive_shell }"
  assert_shell xterm "$shell" -ic "$interactive_shell"
done
assert_shell xterm "$bash_bin" -ilc '[ "$local_rc_count" = 1 ]'
assert_shell xterm "$zsh_bin" -ic 'bindkey "^[[A" | grep -q up-line-or-beginning-search'
assert_shell xterm "$bash_bin" -ic 'bind -p | grep -q history-search-backward'

if [[ "${1:-}" == --check-bash-completion ]]; then
  assert_shell xterm "$bash_bin" -ic '
    ! command -v carapace >/dev/null || exit 1
    if declare -F _comp_load >/dev/null; then
      _comp_load git || exit 1
    else
      _completion_loader git
      case $? in
        0|124) ;; # Readline uses 124 to retry after loading a completion.
        *) exit 1 ;;
      esac
    fi
    complete -p git
  '
fi

if [[ "${1:-}" == --install-tools ]]; then
  bash "$source_dir/run_after_19-install-shell-tools.sh"
  bash "$source_dir/run_after_19-install-shell-tools.sh"
  unset CHEZMOI_PROMPT
  integrations='
    [ "$STARSHIP_CONFIG" = "$HOME/.config/starship.toml" ] &&
      [ -n "$STARSHIP_SHELL" ] && [ -n "$ATUIN_SESSION" ] &&
      [ -n "$CARAPACE_BRIDGES" ] && command -v z >/dev/null
  '
  assert_shell xterm "$bash_bin" -ilc "$integrations"
  assert_shell xterm "$zsh_bin" -ilc "$integrations"
  if [[ "$(uname -s)" == Darwin ]]; then
    assert_shell xterm /bin/bash -ilc 'command -v z >/dev/null && [ -n "$STARSHIP_SHELL" ]'
  fi
fi

printf 'Shell smoke tests passed (%s).\n' "$(uname -s)"
