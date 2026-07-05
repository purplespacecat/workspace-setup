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
- **zoxide doctor false-positives in non-interactive shells** (AI-agent/tool
  shells, scripts) even when init *is* last — precmd hooks never register there,
  and the warning pollutes every command's output (burns AI context tokens).
  `export _ZO_DOCTOR=0` before the init line silences it; interactive behavior
  is unaffected.
- **1Password desktop-app CLI integration only accepts the system `op`** — it
  validates root ownership + setgid `onepassword-cli` (`-rwxr-sr-x root
  onepassword-cli /usr/bin/op`). A user-local copy (`~/.local/bin/op`) fails with
  the misleading `connecting to desktop app: read: connection reset`, and it also
  makes a `command -v op` install-guard skip the system package — guard on
  `rpm -q 1password-cli` instead, and warn about stray user copies (they shadow
  the system binary in PATHs that put `~/.local/bin` first, e.g. systemd units).
- **rclone connection-string colon trap**: in an inline remote like
  `:crypt,remote=gdrive:path:` the parser cuts the option value at the first
  `:`, so `remote=gdrive` resolves to a **local `./gdrive` directory**
  (cwd-relative) and the "backup" silently never leaves the machine. Always
  define a named crypt remote (`rclone config create gdrive-crypt crypt
  remote=gdrive:path`) and target `gdrive-crypt:`. Crypt passwords don't need to
  live in the config — `RCLONE_CRYPT_PASSWORD(_2)` env vars (obscured) act as
  defaults, which is how `config/backup/vault-backup.sh` injects them from
  1Password. Vault restore guide lives in the 1Password item
  `obsidian-vault-backup`.

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

- **Infra tooling is opt-in** (`install-infra-fedora.sh`, deliberately NOT run by
  `setup.sh`) — kubectl, k9s, flux, with an `install_gh_bin` helper for adding
  more. None of these are in Fedora's repos:
  - **kubectl**: use the official `pkgs.k8s.io` dnf repo. It is
    **per-minor-version** — the minor (e.g. `v1.36`) must be in the baseurl; there
    is no "latest" stream. The script derives it from
    `dl.k8s.io/release/stable.txt` so it stays current.
  - **k9s / flux**: GitHub release binaries (same pattern as lazygit/yazi). k9s
    asset is `k9s_Linux_amd64.tar.gz` (upstream switched `x86_64` → `amd64`); flux
    asset embeds the version with **no leading v**: `flux_<ver>_linux_amd64.tar.gz`.
  - **helm**: distributed from `get.helm.sh` (not GitHub assets); the binary is
    **nested** in the tarball at `linux-amd64/helm`, so that's the inner path
    passed to `install_gh_bin`.
  - **kustomize**: the `kubernetes-sigs/kustomize` repo publishes several products,
    so `/releases/latest` may point at a non-kustomize component — filter for the
    `kustomize/vX.Y.Z` tag instead. The slash in that tag must be **URL-encoded
    (`%2F`)** in the download path.
