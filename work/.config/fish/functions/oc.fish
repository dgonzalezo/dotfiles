function oc --description 'opencode wrapper that auto-applies personal overrides in the urbancompass monorepo'
    set -l overrides_file "$HOME/.config/opencode/urbancompass-overrides.json"
    set -l urbancompass_root "$HOME/development/urbancompass"

    # If we're inside the urbancompass repo and the overrides file exists,
    # merge it on top of the project's opencode.json via OPENCODE_CONFIG.
    # This avoids touching the version-controlled .ai/opencode.json.
    set -l current_dir (pwd -P)
    if string match --quiet "$urbancompass_root*" "$current_dir"; and test -f "$overrides_file"
        OPENCODE_CONFIG="$overrides_file" command opencode $argv
    else
        command opencode $argv
    end
end
