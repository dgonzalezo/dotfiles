# =============================================================================
# Urban Compass-specific fish overrides
# =============================================================================
# Auto-loaded by fish from ~/.config/fish/conf.d/ after config.fish runs.
# Contains everything that's specific to working at Urban Compass: PATH entries,
# tool wrappers, MDM CA bundles, etc.
# =============================================================================

set -gx UC_REPO_ROOT $HOME/development/urbancompass

# -----------------------------------------------------------------------------
# Convenience: open Neovim inside a UC service/module
# -----------------------------------------------------------------------------
alias ncuc="cd $UC_REPO_ROOT && nvim"

function ncuc_module -d "Open Neovim in a specific UC service/module"
    set -l service $argv[1]

    if test -z "$service"
        cd $UC_REPO_ROOT
        nvim
    else if string match -q "*/*" $service
        cd $UC_REPO_ROOT
        nvim $service
    else
        # Try Go first, then Python, then Java
        set -l full_path "src/go/compass.com/$service"
        if test -d "$UC_REPO_ROOT/$full_path"
            cd $UC_REPO_ROOT
            nvim $full_path
        else
            for dir in "src/python3/uc/$service" "src/java/compass/com/urbancompass/$service"
                if test -d "$UC_REPO_ROOT/$dir"
                    cd $UC_REPO_ROOT
                    nvim $dir
                    return
                end
            end
            echo "Module '$service' not found in standard locations, opening from repo root"
            cd $UC_REPO_ROOT
            nvim
        end
    end
end

alias nm="ncuc_module"

# -----------------------------------------------------------------------------
# `compass` CLI shortcuts
# -----------------------------------------------------------------------------
alias cx="compass"
alias cw="compass workspace"

# Autocomplete for `compass`
function __complete_compass
    set -lx COMP_LINE (commandline -cp)
    test -z (commandline -ct)
    and set COMP_LINE "$COMP_LINE "
    /usr/local/bin/compass
end
complete -f -c compass -a "(__complete_compass)"

# -----------------------------------------------------------------------------
# Java toolchain (jenv)
# -----------------------------------------------------------------------------
set -gx PATH "$HOME/.jenv/bin" $PATH
if command -v jenv >/dev/null
    status is-interactive; and jenv init - fish | source
end

# -----------------------------------------------------------------------------
# Go toolchain
# -----------------------------------------------------------------------------
set -gx PATH $HOME/go/bin $PATH

# -----------------------------------------------------------------------------
# Compass-managed AI tooling (these blocks were originally injected by
# `compass setup` with the ##compass5ea843 marker)
# -----------------------------------------------------------------------------
function claude --wraps claude
    set -lx HNVM_NODE 22.14.0
    command claude $argv
end

function gemini --wraps gemini
    set -lx HNVM_NODE 22.14.0
    command gemini $argv
end

function opencode --wraps opencode
    set -lx HNVM_NODE 22.14.0
    command opencode $argv
end

set -gx ANTHROPIC_VERTEX_PROJECT_ID gemini-enterprise-485614
set -gx CLAUDE_CODE_USE_VERTEX 1
set -gx CLOUD_ML_REGION global
set -gx GOOGLE_CLOUD_PROJECT gemini-enterprise-485614
set -gx GOOGLE_CLOUD_LOCATION global

# -----------------------------------------------------------------------------
# Compass MDM-issued CA bundle (combines corporate & public roots).
# Required for Python/Node/curl to trust internal Compass services.
# -----------------------------------------------------------------------------
set -l mdm_bundle "$HOME/.mdm/certificates/combined-ca-bundle.pem"
if test -f $mdm_bundle
    set -gx AWS_CA_BUNDLE $mdm_bundle
    set -gx NODE_EXTRA_CA_CERTS $mdm_bundle
    set -gx CURL_CA_BUNDLE $mdm_bundle
    set -gx REQUESTS_CA_BUNDLE $mdm_bundle
    set -gx SSL_CERT_FILE $mdm_bundle
end

# -----------------------------------------------------------------------------
# Python (Library/Python/3.9 brings system tools like ansible/yamllint when used)
# -----------------------------------------------------------------------------
fish_add_path $HOME/Library/Python/3.9/bin
