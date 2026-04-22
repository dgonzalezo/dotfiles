#!/usr/bin/env bash
# =============================================================================
# bin/cutover-incremental.sh
# =============================================================================
# Migrates a SINGLE tool (e.g. lazygit, ghostty, fish) from real files in
# ~/.config to symlinks pointing at ~/.dotfiles, ONE TOOL AT A TIME.
#
# Why incremental?
#   Doing the full cutover in one shot is risky on a working machine. This
#   script lets you do it tool by tool, validate each step in your shell,
#   and roll back instantly if something breaks.
#
# Safety:
#   - Files are MOVED to a `.preinstall.bak` sibling, never deleted.
#   - Re-running the script for the same tool is a no-op once symlinked.
#   - There is a `--rollback` mode that puts the originals back.
#
# Usage:
#   bin/cutover-incremental.sh <profile> <path>
#   bin/cutover-incremental.sh --rollback <profile> <path>
#   bin/cutover-incremental.sh --list <profile>
#
# Examples:
#   bin/cutover-incremental.sh shared lazygit                          # whole dir
#   bin/cutover-incremental.sh shared ghostty
#   bin/cutover-incremental.sh shared starship.toml                    # single file at top
#   bin/cutover-incremental.sh shared opencode/opencode-notifier.json  # single file in subdir
#   bin/cutover-incremental.sh work opencode/urbancompass-overrides.json
#   bin/cutover-incremental.sh --rollback shared lazygit
#
# <path> can be:
#   - a directory under <profile>/.config/   (e.g. lazygit, ghostty, nvim, fish)
#   - a top-level file in <profile>/.config/ (e.g. starship.toml)
#   - a subpath inside one of those dirs     (e.g. opencode/opencode-notifier.json)
#
# Use subpaths when a directory contains a mix of repo-managed files and
# purely local files (e.g. ~/.config/opencode/ has opencode.json with secrets
# alongside opencode-notifier.json which is in the repo).
# =============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="$HOME"

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[0;33m'
BLUE=$'\033[0;34m'; BOLD=$'\033[1m'; RESET=$'\033[0m'

log()  { printf '%s==>%s %s\n' "$BLUE"   "$RESET" "$*"; }
ok()   { printf '%sok%s  %s\n' "$GREEN"  "$RESET" "$*"; }
warn() { printf '%s!!%s  %s\n' "$YELLOW" "$RESET" "$*" >&2; }
err()  { printf '%sxx%s  %s\n' "$RED"    "$RESET" "$*" >&2; exit 1; }

usage() {
  sed -n '1,/^# ==/{p;};/^# ==/q' "$0" | sed 's/^# \{0,1\}//'
  exit 1
}

list_tools() {
  local profile="$1"
  local profile_root="$REPO_DIR/$profile/.config"
  if [[ ! -d "$profile_root" ]]; then
    err "Profile '$profile' not found or has no .config dir."
  fi
  log "Tools available in profile '$profile':"
  ( cd "$profile_root" && find . -mindepth 1 -maxdepth 1 -print | sed 's|^\./|  |' )
}

# ---------------------------- arg parsing -----------------------------------
ROLLBACK=0
[[ $# -ge 1 ]] || usage

case "${1:-}" in
  -h|--help) usage ;;
  --list)    [[ $# -eq 2 ]] || err "Usage: --list <profile>"; list_tools "$2"; exit 0 ;;
  --rollback) ROLLBACK=1; shift ;;
esac

[[ $# -eq 2 ]] || usage
PROFILE="$1"
TOOL="$2"

case "$PROFILE" in
  shared|personal|work) ;;
  *) err "Unknown profile '$PROFILE'. Valid: shared, personal, work" ;;
esac

# Where the source lives in the repo
SRC_PARENT="$REPO_DIR/$PROFILE/.config"
SRC="$SRC_PARENT/$TOOL"

# Where it lands in ~/.config
DST="$TARGET/.config/$TOOL"

if [[ ! -e "$SRC" ]]; then
  err "Source not found: $SRC"
fi

# ---------------------------- rollback --------------------------------------
if [[ $ROLLBACK -eq 1 ]]; then
  if [[ -L "$DST" ]]; then
    log "Removing symlink: $DST"
    rm "$DST"
  elif [[ -e "$DST" ]]; then
    warn "$DST exists but is not a symlink. Not touching."
  fi
  if [[ -e "$DST.preinstall.bak" ]]; then
    log "Restoring backup: $DST.preinstall.bak  ->  $DST"
    mv "$DST.preinstall.bak" "$DST"
    ok "Restored."
  else
    warn "No backup found at $DST.preinstall.bak (nothing to restore)."
  fi
  exit 0
fi

# ---------------------------- forward cutover -------------------------------
# 1. If already a symlink to the right place, do nothing.
if [[ -L "$DST" ]]; then
  current_target="$(readlink "$DST")"
  case "$current_target" in
    *"/.dotfiles/$PROFILE/.config/$TOOL"|*"/.dotfiles/$PROFILE/.config/$TOOL/")
      ok "$DST is already symlinked correctly. Nothing to do."
      exit 0
      ;;
    *)
      err "$DST is a symlink, but points elsewhere: $current_target"
      ;;
  esac
fi

# 2. If a real file/dir exists, move it aside.
if [[ -e "$DST" ]]; then
  if [[ -e "$DST.preinstall.bak" ]]; then
    err "Backup already exists: $DST.preinstall.bak. Please clean it up manually."
  fi
  log "Moving existing $DST  ->  $DST.preinstall.bak"
  mv "$DST" "$DST.preinstall.bak"
fi

# 3. Make sure parent dir exists
mkdir -p "$(dirname "$DST")"

# 4. Stow only that tool. We use stow with --no-folding so adding more profiles
#    later won't trip on a fully-folded directory.
log "Stowing $PROFILE/.config/$TOOL  ->  $DST"
ln -s "$SRC" "$DST"

ok "Cutover complete: $TOOL ($PROFILE)"
echo ""
echo "${BOLD}Verify:${RESET}"
echo "  ls -la $DST"
echo "  readlink $DST"
echo ""
echo "${BOLD}If something breaks, roll back with:${RESET}"
echo "  $0 --rollback $PROFILE $TOOL"
echo ""
echo "${BOLD}When you're confident this tool is fine, you can delete its backup:${RESET}"
echo "  rm -rf $DST.preinstall.bak"
