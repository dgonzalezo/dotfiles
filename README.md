# dotfiles

macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/), organized into composable profiles.

> Inspired by [@josephschmitt/dotfiles](https://github.com/josephschmitt/dotfiles).
> The previous Linux contents of this repo (bspwm / polybar / sxhkd / etc., 2022) are preserved on the [`archive/linux-2022`](https://github.com/dgonzalezo/dotfiles/tree/archive/linux-2022) branch.

---

## Profiles

| Profile      | Purpose                                                                                            |
|--------------|----------------------------------------------------------------------------------------------------|
| `shared/`    | Tools used on every Mac: fish, neovim (LazyVim), lazygit, ghostty, starship, opencode base config |
| `personal/`  | Personal-Mac-only configs (currently empty)                                                       |
| `work/`      | Urban Compass overrides: `oc` fish wrapper, `urbancompass.fish`, OpenCode `urbancompass-overrides.json` |

Profiles are stowed independently so you can mix them as needed.

---

## Quick Start

```bash
git clone https://github.com/dgonzalezo/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

Then pick the scenario that matches your machine:

### Personal Mac
```bash
./install.sh shared personal
```

### Work Mac (Urban Compass)
```bash
./install.sh shared work
```

### Someone cloning who isn't me
```bash
./install.sh shared
```

The installer:

1. Installs Homebrew if missing.
2. Installs core deps: `stow`, `fish`, `neovim`, `lazygit`, `starship`, `zoxide`, `fzf`, `ripgrep`, `fd`, `bat`, `eza`, `gh`, plus Ghostty as a cask.
3. Runs `stow` for each profile (with a dry-run conflict check first).
4. Prints post-install steps (chsh to fish, install fish plugins via fisher, open nvim/opencode once for first-run setup).

---

## What's included

### `shared/`

| Path                                                | What                                                                                |
|-----------------------------------------------------|-------------------------------------------------------------------------------------|
| `.config/fish/config.fish`                          | Fish: PATH, aliases, NVM bridge, starship + zoxide init, opencode CLI on PATH       |
| `.config/fish/functions/fish_user_key_bindings.fish`| Vi mode + peco bindings                                                             |
| `.config/fish/functions/claude.fish`                | Wrapper stub for `claude`                                                           |
| `.config/fish/fish_plugins`                         | Plugin list for [fisher](https://github.com/jorgebucaran/fisher)                    |
| `.config/nvim/`                                     | LazyVim + custom `lspconfig.lua` with gopls memory tweaks (only active when `~/development/urbancompass` exists) |
| `.config/lazygit/config.yml`                        | Lazygit tuned for huge monorepos (no delta pager, refreshInterval=60, no graph)     |
| `.config/ghostty/config`                            | Ghostty: tokyonight theme, vim-style splits, quick terminal, desktop notifications |
| `.config/starship.toml`                             | Starship prompt                                                                     |
| `.config/opencode/opencode-notifier.json`           | Config for [@mohak34/opencode-notifier](https://www.npmjs.com/package/@mohak34/opencode-notifier) |
| `.config/opencode/package.json`                     | Pins `@opencode-ai/plugin` for Bun                                                  |
| `.config/opencode/opencode.example.json`            | Template (without secrets) for the global OpenCode config — see _Secrets_ below     |

### `work/`

| Path                                                  | What                                                                              |
|-------------------------------------------------------|-----------------------------------------------------------------------------------|
| `.config/fish/conf.d/urbancompass.fish`               | UC_REPO_ROOT, `ncuc`/`ncuc_module` aliases, `compass` autocomplete, jenv, MDM CA bundle |
| `.config/fish/functions/oc.fish`                      | `oc` = `opencode` wrapper that auto-applies UC overrides when inside the monorepo |
| `.config/opencode/urbancompass-overrides.json`        | OpenCode overrides: `snapshot=false` and watcher ignore list (avoids 1.4 GB snapshot bloat from Bazel/mocks) |

### `personal/`

Empty for now. Add personal-only tweaks here.

---

## Secrets

The following files are **gitignored** and never make it to GitHub:

| File                                          | Why                                                                  |
|-----------------------------------------------|----------------------------------------------------------------------|
| `~/.config/opencode/opencode.json`            | Contains Onyx MCP gateway API keys, Obsidian API key, Fireworks-AI baseURL with embedded token |
| `~/.config/opencode/opencode-notifier-state.json` | Runtime state                                                    |
| `~/.config/fish/fish_variables`               | Fish universal variables (per-machine state)                         |
| `~/.config/lazygit/state.yml`                 | Lazygit runtime state                                                |
| `~/.config/opencode/node_modules/`, `bun.lock`, `package-lock.json` | Runtime artifacts; reinstalled by Bun on first opencode launch |
| Anything matching `*.local`, `*.private`, `.env`, `*.token` | Generic secret patterns                                |

After install, copy the OpenCode example config and fill in your own values:

```bash
cp ~/.config/opencode/opencode.example.json ~/.config/opencode/opencode.json
$EDITOR ~/.config/opencode/opencode.json
```

---

## Notable design decisions

- **`gopls` config has a directory guard.** `shared/.config/nvim/lua/plugins/lspconfig.lua` returns `{}` unless `~/development/urbancompass` exists. So on a non-Compass Mac you get LazyVim's default Go setup; on a Compass Mac you get the memory-optimized one (`memoryMode=DegradeClosed`, `expandWorkspaceToModule=false`, etc.) that prevents gopls from eating 15 GB indexing the 474-package monorepo.

- **`oc` instead of `opencode` at work.** `work/.config/fish/functions/oc.fish` checks if `pwd` is inside `~/development/urbancompass`. If so, it sets `OPENCODE_CONFIG=~/.config/opencode/urbancompass-overrides.json` and merges `snapshot=false` + watcher ignores on top of the project's `.ai/opencode.json`. Outside the monorepo, `oc` runs vanilla opencode. This avoids touching the version-controlled config that's shared with the whole team.

- **Lazygit pager is `cat`, not `delta`.** On a 121k-file / 196k-commit monorepo, delta can balloon to multi-GB rendering large diffs.

- **Fish plugins are NOT vendored.** `tide`, `nvm.fish`, `bass`, `peco` are reinstalled via fisher on first run — only `fish_plugins` is committed.

- **`lazy-lock.json` IS committed.** Pins LazyVim plugin versions across machines.

---

## License

[MIT](./LICENSE)
