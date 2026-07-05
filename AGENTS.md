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

## Branch Discipline

- Prefer feature branches for ordinary code changes.
- Direct commits on `main` are allowed when the user explicitly requests work on `main`.
- Direct pushes from `main` are allowed only when the user explicitly requests the push.
- Do not bypass validation, task hygiene, or review loops when working directly on `main`.
