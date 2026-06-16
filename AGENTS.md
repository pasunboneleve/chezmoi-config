# AGENTS.md

## Git Remotes And Clones

- Use SSH URLs for GitHub remotes, all `git clone` commands, and Git-backed package installs.
- Prefer `git@github.com:owner/repo.git`.
- Do not introduce HTTPS GitHub clone URLs.

## Node Apps

- Install Node applications with Bun instead of npm.
- Prefer `bun add -g <package>` for global JavaScript CLI packages.

## Roborev Reviews

- Roborev reviews may use external model providers when needed to complete the repository review loop.
