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

`colorize_errors` reads command output on standard input and highlights common package-manager error lines. Do not call it directly for ordinary install commands; call it through `run_with_colored_errors` so the original command status is preserved.

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

## `configure_xremap_permissions`

Use `configure_xremap_permissions` only in the Linux branch before or after installing `xremap-gnome`. It owns the local system setup needed for user-level xremap services:

- creates the `input` group when missing;
- adds the current user to `input`;
- loads `uinput`;
- writes the udev rule for `/dev/uinput`.

Do not call it on macOS. If xremap setup changes, keep the permission logic inside this helper so the Linux package branch stays readable.
