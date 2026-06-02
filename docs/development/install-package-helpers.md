# Install Package Helpers

[`run_before_10-install-packages.sh.tmpl`](../../run_before_10-install-packages.sh.tmpl) is a [chezmoi](https://www.chezmoi.io/) script template. The script exits unless `CHEZMOI_INSTALL_PACKAGES=1` is set, so helper calls should be safe to rerun during normal `chezmoi --source . apply`.

## Adding Install Steps

Place new install steps in the operating-system branch that owns the dependency. Keep each step idempotent by checking the executable or target file first.

```bash
if ! command -v example >/dev/null 2>&1; then
  install command here
fi
```

Use plain commands when the package manager already reports errors clearly. Use the helpers below when they preserve a repeated pattern.

## `colorize_errors`

`colorize_errors` reads command output on standard input and highlights common warning and error lines. Errors are red; warnings are yellow. It covers package-manager output, Emacs memory failures, timeout failures, and chezmoi script errors.

Do not call it directly for ordinary install commands; call it through `run_with_colored_errors` so the original command status is preserved.

```bash
some_command 2>&1 | colorize_errors
```

Use direct calls only when the command status is handled somewhere else.

## `run_with_colored_errors`

Use `run_with_colored_errors` for commands whose output benefits from error highlighting but whose exit status must still fail the script. Pass the command and its arguments directly.

```bash
run_with_colored_errors sudo dnf install -y \
  package-one \
  package-two
```

Do not wrap the command in a quoted string. The helper executes the arguments as a command, pipes combined output through `colorize_errors`, and returns the original command status.

## `install_from_script`

Use `install_from_script` only for installers that are intentionally distributed as remote shell scripts. Pass a display name and the installer URL.

```bash
if ! command -v tool >/dev/null 2>&1; then
  install_from_script tool https://example.com/install.sh
fi
```

Prefer a package manager or `go install` when the project provides one. Remote installer scripts are harder to audit, so keep each call behind an executable check.

## `install_js_package`

Use `install_js_package` for global [Bun](https://bun.sh/) or `npm` packages that expose an executable on `PATH`. The first argument is the executable to check; the second is the package name to install.

```bash
install_js_package some-command some-package
```

The helper prefers `bun install -g`. It falls back to `npm install -g` only when `CHEZMOI_USE_NPM_FOR_JS_PACKAGES=1` is set and `npm` is available.

There are no current JavaScript package installs. Add future calls near the other language-specific tool installs in each operating-system branch.

## `ensure_gh_extension`

Use `ensure_gh_extension` for GitHub CLI extensions after `gh` has been
installed by the operating-system package branch. Pass the extension command
name without the `gh` prefix, then the repository URL to install.

```bash
ensure_gh_extension example ssh://git@github.com/owner/gh-example.git
```

Use SSH URLs for GitHub-hosted extensions, matching
[`AGENTS.md`](../../AGENTS.md). The helper checks `gh extension list` first and
installs only when the extension command is missing.

## `ensure_rust_toolchain`

Use `ensure_rust_toolchain` before any `cargo install` calls. It updates Rust when `rustup` is available, leaves package-manager Rust installations alone when `cargo` already exists, and installs Rust with `rustup` only when neither `rustup` nor `cargo` is present.

```bash
ensure_rust_toolchain

if ! command -v tool >/dev/null 2>&1; then
  cargo install tool
fi
```

The script adds `~/.cargo/bin` to `PATH` before this helper runs, so tools installed by rustup are available later in the same bootstrap run.

## `ensure_emacs`

Use `ensure_emacs` before any Emacs batch command. The helper returns when `emacs` is already on `PATH`, otherwise it installs Emacs with the same package manager used by the operating-system branch: `dnf` on Linux, or Homebrew on macOS.

```bash
ensure_emacs
```

The helper exits with an error when Emacs is missing and neither `dnf` nor `brew` is available.

## `ensure_emacs_config`

Use `ensure_emacs_config` before running Emacs against the personal config. It keeps `~/.config/emacs` present as a Git checkout of `git@github.com:pasunboneleve/emacs.d.git`.

```bash
ensure_emacs_config
```

If the checkout exists, the helper updates it with `git pull --ff-only`. If `~/.config/emacs` exists but is not a Git checkout, it exits instead of overwriting local files.

All GitHub clones in this repository should use SSH URLs, matching [`AGENTS.md`](../../AGENTS.md).

## Emacs Batch Resource Controls

The Emacs batch setup reduces peak memory use and bounds stalled runs with these controls:

- sets `elpaca-queue-limit` before loading the config, defaulting to one package build at a time;
- sets `NATIVE_DISABLED=1` by default, so package installation byte-compiles without native-compiling.
- wraps the batch run in `timeout` or `gtimeout`, defaulting to 30 minutes, so a stalled Elpaca wait fails visibly.

Override those defaults with:

```bash
CHEZMOI_ELPACA_QUEUE_LIMIT=2
CHEZMOI_EMACS_BATCH_NATIVE_DISABLED=0
CHEZMOI_EMACS_BATCH_TIMEOUT=1h
```

Increase the queue limit only on machines with enough memory for parallel package builds. Enable native compilation only when the extra memory use is acceptable during bootstrap. Increase the timeout only when the batch process is still producing package, build, or network activity.

## `install_emacs_packages`

Use `install_emacs_packages` after every other install step in the operating-system branch. It ensures Emacs is installed, ensures the config checkout exists, then runs Emacs in batch mode to update Elpaca menus and wait for queued package work.

```bash
install_emacs_packages
```

Keep this call at the end of each branch so Emacs sees tools installed earlier in the bootstrap run.

Keep the progress messages around Emacs install, config sync, and batch setup. The Elpaca step can take long enough that the bootstrap should say which phase is running.

## `configure_xremap_permissions`

Use `configure_xremap_permissions` only in the Linux branch before or after installing `xremap-gnome`. It owns the local system setup needed for user-level xremap services:

- creates the `input` group when missing;
- adds the current user to `input`;
- loads `uinput`;
- writes the udev rule for `/dev/uinput`.

Do not call it on macOS. If xremap setup changes, keep the permission logic inside this helper so the Linux package branch stays readable.
