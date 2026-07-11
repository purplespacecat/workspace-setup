#!/usr/bin/env bash
# Claude Code config backup: ~/.claude → Google Drive (rclone, UNENCRYPTED).
#
# ALLOWLIST, not denylist: only portable config is synced. This is the safety
# mechanism for an unencrypted destination — a new secret file appearing in
# ~/.claude can never be swept to Google Drive because it isn't on the list.
# Deliberately EXCLUDED (secret / private / bulky): .credentials.json (OAuth
# tokens), history.jsonl, sessions/, projects/ (conversation transcripts),
# shell-snapshots/, remote-settings.json, policy-limits.json, settings.local.json.
#
# Plugins: back up the MANIFEST (installed_plugins.json + known_marketplaces.json)
# — the declaration of what's installed — NOT the marketplaces/ and cache/ trees.
# Those are large, churn daily, and are reproducible: a restore re-adds the
# marketplaces and reinstalls from the manifest. User-authored customisation
# lives in skills/ commands/ agents/ (top-level), which ARE backed up in full.
#
# Named [gdrive] remote (NOT an inline ":path:" connection string — that parses
# to a LOCAL ./gdrive dir; see vault-backup.sh / LEARNINGS.md rclone colon trap).
set -euo pipefail

SRC="$HOME/.claude"

# `sync` mirrors (a clean restore image); the dedicated destination path plus
# the include-only filter mean it can only ever touch allowlisted config.
exec rclone sync "$SRC" "gdrive:claude-config" \
  --include "/CLAUDE.md" \
  --include "/settings.json" \
  --include "/skills/**" \
  --include "/commands/**" \
  --include "/agents/**" \
  --include "/plugins/installed_plugins.json" \
  --include "/plugins/known_marketplaces.json" \
  --create-empty-src-dirs \
  --log-level NOTICE
