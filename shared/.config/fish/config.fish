# =============================================================================
# fish config (shared / universal)
# =============================================================================
# Anything specific to a host or a workplace lives in conf.d/*.fish, which fish
# auto-loads alphabetically after this file. See work/.config/fish/conf.d/ in
# the dotfiles repo for the Urban Compass-specific overrides.
# =============================================================================

set fish_greeting ""

set -gx TERM xterm-256color

# Ensure XDG-aware tools (lazygit, neovim, opencode, ghostty, etc.) read from
# ~/.config on macOS. Without this, lazygit silently uses
# ~/Library/Application Support/lazygit/ instead, ignoring our config entirely.
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_STATE_HOME $HOME/.local/state
set -gx XDG_CACHE_HOME $HOME/.cache

# theme
set -g theme_color_scheme
set -g fish_prompt_pwd_dir_length 1
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_hostname always

# aliases
alias ls "ls -p -G"
alias la "ls -A"
alias ll "ls -l"
alias lla "ll -A"
alias g git
alias v nvim
command -qv nvim && alias v nvim

set -gx EDITOR nvim

# Base PATH
set -gx PATH bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/.local/bin $PATH

# Per-OS extras (kept from the previous setup; harmless if files don't exist)
switch (uname)
    case Darwin
        if test -f (dirname (status --current-filename))/config-osx.fish
            source (dirname (status --current-filename))/config-osx.fish
        end
    case Linux
        if test -f (dirname (status --current-filename))/config-linux.fish
            source (dirname (status --current-filename))/config-linux.fish
        end
    case '*'
        if test -f (dirname (status --current-filename))/config-windows.fish
            source (dirname (status --current-filename))/config-windows.fish
        end
end

# Local untracked overrides (NOT in dotfiles repo, gitignored)
set LOCAL_CONFIG (dirname (status --current-filename))/config-local.fish
if test -f $LOCAL_CONFIG
    source $LOCAL_CONFIG
end

# =============================================================================
# NVM (Homebrew install) - Fish-compatible wrapper
# =============================================================================
set -gx NVM_DIR $HOME/.nvm

if test -d $NVM_DIR
    function nvm
        bash -c "source $NVM_DIR/nvm.sh; nvm $argv"
    end

    # Load latest installed Node into PATH on startup
    set -l latest_node (ls -t $NVM_DIR/versions/node 2>/dev/null | head -1)
    if test -n "$latest_node"
        set -gx PATH $NVM_DIR/versions/node/$latest_node/bin $PATH
    end

    # Auto-switch on .nvmrc when changing directory
    function __check_nvmrc --on-variable PWD
        status is-command-substitution; and return
        if test -f .nvmrc
            set -l version (cat .nvmrc | tr -d '[:space:]' | sed 's/^v//')
            if test -n "$version"
                bash -c "source $NVM_DIR/nvm.sh && nvm use $version" >/dev/null 2>&1
                if test -d $NVM_DIR/versions/node/v$version/bin
                    set -gx PATH $NVM_DIR/versions/node/v$version/bin $PATH
                end
            end
        end
    end
    __check_nvmrc
end

# Cargo (Rust)
set -Ua fish_user_paths $HOME/.cargo/bin

# Starship prompt
starship init fish | source

# Zoxide (smarter cd)
zoxide init fish | source

# OpenCode CLI (installed under ~/.opencode/bin)
fish_add_path $HOME/.opencode/bin

# Increase open-file limit (helps tools that watch many files)
set -gx RLIMIT_NOFILE 4096
