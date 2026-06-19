# LEARNINGS.md

Repo-specific gotchas and non-obvious facts discovered while working on these
setup scripts. Read this before touching install logic; add an entry whenever a
fix turns out to be non-obvious (especially upstream changes that break a pinned
URL, module path, or package name).

## Fedora

- **Secrets workflow is 1Password (`op` CLI)** — not bw/sops/age (dropped
  2026-06-19 after a work-provided free 1Password Family plan became available).
  `op` has a native rpm: install from 1Password's official dnf repo
  (`downloads.1password.com/linux/rpm/stable`), not via `go`/`npm`. The workflow
  is `op run --env-file=.env` + `op://vault/item/field` references — no local key
  material to back up (unlike the old sops/age age-key).
- **direnv needs a shell hook** to work: `eval "$(direnv hook zsh)"` in `.zshrc`.
  It's packaged in the Fedora repos (in `pkglist.txt`) and the hook lives in
  `config/shell/.zshrc` *before* the zoxide init (zoxide's doctor insists on being
  initialized last). Pairs with `op run` for per-project env loading.

- **obsidian-cli was renamed to `notesmd-cli`** (2026-06). The upstream module
  `github.com/Yakitrak/obsidian-cli` now declares its path as
  `github.com/Yakitrak/notesmd-cli`, so `go install …/obsidian-cli@latest` fails
  with a "module declares its path as" version-constraint error. Install via
  `go install github.com/Yakitrak/notesmd-cli@latest`; the binary is
  `~/go/bin/notesmd-cli`. The CLI's commands also changed: vaults are registered
  with `add-vault <path>` and the default is set with `set-default-vault <name>`
  (the old `set-default --path` is gone).
- **Obsidian has no native rpm** — install via Flatpak (`md.obsidian.Obsidian`),
  which is preinstalled on Fedora Workstation/KDE.
- **zsh completions** live in `~/.zsh_functions/`, which `config/shell/.zshrc`
  adds to `fpath` (look for the `fpath+=...zsh_functions` line). Dropping a
  `_<tool>` file there is enough — oh-my-zsh runs `compinit`, no `.zshrc` edit
  needed. If a new completion doesn't show up, clear the cache:
  `rm -f ~/.zcompdump* && exec zsh`.
- **`curl` is deliberately not in pkglist / `dnf install`** — listing it forces a
  swap from `curl-minimal` (shipped in `@core`) to full `curl`. See the comment
  in `install-zsh-fedora.sh`.
