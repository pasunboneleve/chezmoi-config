#!/usr/bin/env bash
set -euo pipefail

# This hook can also run directly for a shell-only setup without sudo.
bin_dir="$HOME/.local/bin"
export PATH="$bin_dir:$PATH"

install_release() (
  set -e
  local executable="$1" repository="$2" tag="$3" asset="$4"
  local staging binary

  if command -v "$executable" >/dev/null 2>&1; then
    return
  fi

  mkdir -p "$bin_dir"
  staging="$(mktemp -d "$bin_dir/.shell-tool.XXXXXXXX")"
  trap 'rm -rf "$staging"' EXIT
  echo "Installing $executable $tag."
  curl -fsSL --proto '=https' --proto-redir '=https' --retry 2 \
    "https://github.com/$repository/releases/download/$tag/$asset" -o "$staging/release.tar.gz"
  tar -xzf "$staging/release.tar.gz" -C "$staging"
  binary="$(find "$staging" -type f -name "$executable" -print -quit)"
  if [ -z "$binary" ]; then
    printf 'Could not find %s in %s.\n' "$executable" "$asset" >&2
    return 1
  fi
  chmod 0755 "$binary"
  mv -f "$binary" "$bin_dir/$executable"
)

case "$(uname -m)" in
  x86_64) rust_arch=x86_64; go_arch=amd64 ;;
  aarch64|arm64) rust_arch=aarch64; go_arch=arm64 ;;
  *) echo "Skipping shell tool downloads on $(uname -m)."; exit 0 ;;
esac
case "$(uname -s)" in
  Linux) rust_target="$rust_arch-unknown-linux-musl"; go_os=linux ;;
  Darwin) rust_target="$rust_arch-apple-darwin"; go_os=darwin ;;
  *) echo "Skipping shell tool downloads on $(uname -s)."; exit 0 ;;
esac

install_release zoxide ajeetdsouza/zoxide v0.9.9 "zoxide-0.9.9-$rust_target.tar.gz"
install_release atuin atuinsh/atuin v18.25.0 "atuin-$rust_target.tar.gz"
install_release carapace carapace-sh/carapace-bin v1.8.1 "carapace-bin_1.8.1_${go_os}_${go_arch}.tar.gz"
install_release starship starship/starship v1.25.1 "starship-$rust_target.tar.gz"
