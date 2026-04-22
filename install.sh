#!/usr/bin/env bash
# =============================================================================
# dotfiles installer
# =============================================================================
# Usage:
#   ./install.sh [profile ...]
#
# Profiles:
#   shared    Tools used on every Mac (fish, neovim, lazygit, ghostty, starship,
#             opencode base config). Always recommended.
#   personal  Personal-Mac-only configs. (Currently empty.)
#   work      Urban Compass overrides (oc fish wrapper, urbancompass.fish,
#             OpenCode urbancompass-overrides.json).
#
# Examples:
#   ./install.sh shared             # someone else cloning the repo
#   ./install.sh shared personal    # personal Mac
#   ./install.sh shared work        # work Mac
#
# What it does:
#   1. Checks we're on macOS.
#   2. Installs Homebrew if missing.
#   3. Installs the Brewfile dependencies (stow, fish, neovim, lazygit, ...).
#   4. Backs up any pre-existing config that would conflict.
#   5. Runs `stow` for each requested profile.
#   6. Prints post-install steps (chsh to fish, etc.).
# =============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KNOWN_PROFILES=(shared personal work)

# ---------------------------- helpers ---------------------------------------
RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[0;33m'
BLUE=$'\033[0;34m'; BOLD=$'\033[1m'; RESET=$'\033[0m'

log()  { printf '%s==>%s %s\n' "$BLUE" "$RESET" "$*"; }
warn() { printf '%s!!%s %s\n' "$YELLOW" "$RESET" "$*" >&2; }
err()  { printf '%sxx%s %s\n' "$RED" "$RESET" "$*" >&2; exit 1; }
ok()   { printf '%sok%s %s\n' "$GREEN" "$RESET" "$*"; }

is_known_profile() {
  local p="$1"
  for kp in "${KNOWN_PROFILES[@]}"; do [[ "$p" == "$kp" ]] && return 0; done
  return 1
}

# ---------------------------- arg parsing -----------------------------------
if [[ $# -eq 0 ]]; then
  cat <<EOF
${BOLD}Usage:${RESET} $0 [profile ...]

Available profiles: ${KNOWN_PROFILES[*]}

Examples:
  $0 shared             # base setup only
  $0 shared personal    # personal Mac
  $0 shared work        # work Mac (Urban Compass)
EOF
  exit 1
fi

PROFILES=()
for arg in "$@"; do
  if is_known_profile "$arg"; then
    PROFILES+=("$arg")
  else
    err "Unknown profile: '$arg'. Valid profiles: ${KNOWN_PROFILES[*]}"
  fi
done

log "Selected profiles: ${PROFILES[*]}"

# ---------------------------- platform check --------------------------------
if [[ "$(uname -s)" != "Darwin" ]]; then
  err "This installer currently only supports macOS."
fi

# ---------------------------- Homebrew --------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  log "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for this session (Apple Silicon path)
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  ok "Homebrew already installed."
fi

# ---------------------------- core deps -------------------------------------
log "Installing core dependencies..."
CORE_PKGS=(
  stow            # symlink farm manager (the whole point of this repo)
  fish            # shell
  neovim          # editor
  lazygit         # git TUI
  starship        # prompt
  zoxide          # smarter cd
  fzf             # fuzzy finder
  ripgrep         # fast grep (used by Telescope/snacks)
  fd              # fast find
  bat             # cat with syntax highlighting
  eza             # ls with icons
  gh              # GitHub CLI
)
for pkg in "${CORE_PKGS[@]}"; do
  if brew list --formula "$pkg" >/dev/null 2>&1; then
    : # already installed
  else
    log "  brew install $pkg"
    brew install "$pkg"
  fi
done
ok "Core dependencies installed."

# Ghostty (cask)
if ! brew list --cask ghostty >/dev/null 2>&1; then
  log "Installing Ghostty (cask)..."
  brew install --cask ghostty || warn "Ghostty install failed (skipping); install manually if needed."
fi

# ---------------------------- Stow ------------------------------------------
# IMPORTANT: we deliberately do NOT use a .stowrc file. Past experience shows
# that having "--target=\$HOME --dir=\$PWD" in .stowrc can interact poorly with
# explicit --target on the command line (stow's de-dup of args can cause it to
# silently skip directories). Using bare flags here avoids that.
#
# --no-folding: never replace a target directory with a single symlink to the
#   package; always create per-file symlinks. This lets multiple profiles
#   (e.g. shared + work) coexist inside the same target subdirectory like
#   ~/.config/fish/.
log "Stowing profiles into \$HOME..."
STOW_FLAGS=(--no-folding --target="$HOME" --dir="$REPO_DIR")

for profile in "${PROFILES[@]}"; do
  if [[ ! -d "$REPO_DIR/$profile" ]]; then
    warn "Profile directory '$profile' doesn't exist, skipping."
    continue
  fi

  # Dry-run conflict check
  conflicts=$(stow "${STOW_FLAGS[@]}" --no -v "$profile" 2>&1 | grep -E "WARNING|conflict|existing target" || true)
  if [[ -n "$conflicts" ]]; then
    warn "Conflicts detected for '$profile':"
    echo "$conflicts" | sed 's/^/    /' >&2
    warn "Resolve them (move pre-existing files aside) and re-run, e.g.:"
    warn "    mv ~/.config/foo ~/.config/foo.preinstall.bak"
    continue
  fi

  log "  stow $profile"
  stow "${STOW_FLAGS[@]}" "$profile"
  ok "  $profile stowed."
done

# ---------------------------- post-install ----------------------------------
cat <<EOF

${BOLD}${GREEN}Done.${RESET}

${BOLD}Next steps:${RESET}

  1. ${BOLD}Switch your login shell to fish:${RESET}
       sudo sh -c 'echo /opt/homebrew/bin/fish >> /etc/shells'
       chsh -s /opt/homebrew/bin/fish

  2. ${BOLD}Install fish plugins (fisher + tide + nvm + bass):${RESET}
       fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
       fish -c 'fisher update'
       # then run: fish -c 'tide configure'

  3. ${BOLD}Open Neovim once${RESET} so LazyVim bootstraps and installs plugins:
       nvim

  4. ${BOLD}Open OpenCode once${RESET} so Bun installs the notifier plugin:
       opencode

  5. ${BOLD}OpenCode secrets:${RESET} the global ~/.config/opencode/opencode.json
     is gitignored. Copy the template and fill in your real keys:
       cp ~/.config/opencode/opencode.example.json ~/.config/opencode/opencode.json
       \$EDITOR ~/.config/opencode/opencode.json

EOF
