#!/usr/bin/env bash
# Encrypted Obsidian vault backup: ~/Documents/obsidian → Google Drive (rclone crypt).
# Client-side encrypted — Google only ever stores ciphertext (contents + filenames).
# Crypt password + salt live in 1Password (op read) — no secret material on disk.
# See vault note: docs/system/vault-backup-rclone.md
set -euo pipefail

VAULT="$HOME/Documents/obsidian"
OP_ITEM="op://Private/obsidian-vault-backup"

RCLONE_CRYPT_PASSWORD="$(rclone obscure "$(op read "$OP_ITEM/password")")"
RCLONE_CRYPT_PASSWORD2="$(rclone obscure "$(op read "$OP_ITEM/salt")")"
export RCLONE_CRYPT_PASSWORD RCLONE_CRYPT_PASSWORD2

# .git included on purpose (history is part of the backup).
# Deletions go to Drive trash (rclone default) — extra safety net.
# NB: target is the named [gdrive-crypt] config remote, NOT an inline
# ":crypt,remote=gdrive:path:" string — the connection-string parser cuts the
# value at the first ":", silently turning the target into a LOCAL ./gdrive dir.
exec rclone sync "$VAULT" "gdrive-crypt:" \
  --exclude ".obsidian/workspace*" \
  --create-empty-src-dirs \
  --fast-list \
  --log-level NOTICE
