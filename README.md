# dotfiles

macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/), organized into composable profiles.

> Inspired by [@josephschmitt/dotfiles](https://github.com/josephschmitt/dotfiles).
> The previous Linux contents of this repo (bspwm / polybar / sxhkd / etc., 2022) are preserved on the [`archive/linux-2022`](https://github.com/dgonzalezo/dotfiles/tree/archive/linux-2022) branch.

---

## Table of contents

- [Profiles](#profiles)
- [Quick start](#quick-start)
- [What's installed and why](#whats-installed-and-why)
  - [Shell: fish + starship + zoxide + fzf + tide](#shell-fish--starship--zoxide--fzf--tide)
  - [Terminal: Ghostty](#terminal-ghostty)
  - [Editor: Neovim + LazyVim](#editor-neovim--lazyvim)
  - [Git TUI: lazygit](#git-tui-lazygit)
  - [AI assistant: OpenCode](#ai-assistant-opencode)
  - [CLI utilities: ripgrep, fd, bat, eza, gh](#cli-utilities-ripgrep-fd-bat-eza-gh)
- [Work profile (Urban Compass-specific)](#work-profile-urban-compass-specific)
- [Cutover on a working machine](#cutover-on-a-working-machine)
- [Secrets handling](#secrets-handling)
- [Notable design decisions](#notable-design-decisions)
- [Learning resources](#learning-resources)
  - [Vim / Neovim](#vim--neovim)
  - [Fish shell](#fish-shell)
  - [Lazygit & git](#lazygit--git)
  - [General terminal productivity](#general-terminal-productivity)
- [License](#license)

---

## Profiles

| Profile      | Purpose                                                                                                  |
|--------------|----------------------------------------------------------------------------------------------------------|
| `shared/`    | Tools used on every Mac: fish, neovim (LazyVim), lazygit, ghostty, starship, opencode base config        |
| `personal/`  | Personal-Mac-only configs (currently empty)                                                              |
| `work/`      | Urban Compass overrides: `oc` fish wrapper, `urbancompass.fish`, OpenCode `urbancompass-overrides.json`  |

Profiles are composable. On a personal Mac use `shared + personal`; on a work Mac use `shared + work`.

---

## Quick start

```bash
git clone https://github.com/dgonzalezo/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

Pick the scenario that matches your machine:

| Scenario              | Command                              |
|-----------------------|--------------------------------------|
| Personal Mac          | `./install.sh shared personal`       |
| Work Mac (Urban Compass) | `./install.sh shared work`        |
| Someone else cloning  | `./install.sh shared`                |

What `install.sh` does:

1. Installs Homebrew if missing.
2. Installs core deps: `stow`, `fish`, `neovim`, `lazygit`, `starship`, `zoxide`, `fzf`, `ripgrep`, `fd`, `bat`, `eza`, `gh`, plus Ghostty as a cask.
3. Runs `stow --no-folding` for each requested profile, with a dry-run conflict check first.
4. Prints post-install steps (chsh to fish, install fish plugins via fisher, open nvim/opencode once for first-run setup).

If you already have a working machine and don't want a one-shot cutover, see [Cutover on a working machine](#cutover-on-a-working-machine) for the incremental migration script.

---

## What's installed and why

This repo configures a small, opinionated stack. Each tool is here for a specific reason; if a tool isn't pulling its weight on your setup, drop it.

### Shell: fish + starship + zoxide + fzf + tide

[**fish**](https://fishshell.com/) — friendly interactive shell with autosuggestions and out-of-the-box history search. We use it as the login shell. Solves: bash/zsh ergonomics without needing 50 plugins.

- Docs: <https://fishshell.com/docs/current/>
- Tutorial: <https://fishshell.com/docs/current/tutorial.html>
- Cookbook: <https://github.com/jorgebucaran/cookbook.fish>

Plugins (managed via [**fisher**](https://github.com/jorgebucaran/fisher)) — see `shared/.config/fish/fish_plugins`:

| Plugin                                                                              | What it does                                              |
|-------------------------------------------------------------------------------------|-----------------------------------------------------------|
| [`jorgebucaran/fisher`](https://github.com/jorgebucaran/fisher)                     | The plugin manager itself                                 |
| [`edc/bass`](https://github.com/edc/bass)                                           | Run bash scripts from fish (NVM, AWS CLI helpers, etc.)   |
| [`jorgebucaran/nvm.fish`](https://github.com/jorgebucaran/nvm.fish)                 | Native NVM port for fish                                  |
| [`ilancosman/tide@v5`](https://github.com/IlanCosman/tide)                          | Asynchronous prompt with git/k8s/aws/lang detection       |

> Note: tide and starship both render prompts. Tide stays installed for its info segments and is loaded after starship for compatibility. If you only want one prompt, pick.

[**starship**](https://starship.rs/) — fast, cross-shell prompt configured in `shared/.config/starship.toml`. Solves: a uniform prompt across fish/bash/zsh.

- Docs: <https://starship.rs/config/>
- Presets: <https://starship.rs/presets/>

[**zoxide**](https://github.com/ajeetdsouza/zoxide) — `cd` that learns your habits. After a few visits, `z proj` jumps to `~/code/some/long/path/projects/`.

- README: <https://github.com/ajeetdsouza/zoxide#readme>
- `man zoxide`

[**fzf**](https://github.com/junegunn/fzf) — fuzzy finder. Used by Neovim's Telescope (`telescope-fzf-native`), lazygit, and as a standalone for history (`Ctrl-R`).

- Docs: <https://github.com/junegunn/fzf#readme>
- Tips: <https://github.com/junegunn/fzf/wiki/Examples>

### Terminal: Ghostty

[**Ghostty**](https://ghostty.org/) — fast, GPU-accelerated terminal by Mitchell Hashimoto. Configured in `shared/.config/ghostty/config`.

What our config does:

- Theme: `tokyonight`
- Font: DejaVuSansM Nerd Font, size 18
- Vim-style split navigation: `opt+h/j/k/l` to move, `opt+shift+h/j/k/l` to create splits
- Tab navigation: `ctrl+h/l` for previous/next tab
- Quick terminal: `ctrl+=` toggles a centered floating terminal (60% × 80%)
- Desktop notifications enabled (used by the OpenCode notifier plugin)
- `bell-features = system,audio,attention` so escape-bell `\a` bounces the dock icon

Docs: <https://ghostty.org/docs>
Config reference: <https://ghostty.org/docs/config/reference>

### Editor: Neovim + LazyVim

[**Neovim**](https://neovim.io/) — a hyperextensible Vim-based text editor. We use it through [**LazyVim**](https://www.lazyvim.org/), a preconfigured starter pack on top of [`folke/lazy.nvim`](https://github.com/folke/lazy.nvim).

LazyVim is the easiest way to start with modern Neovim without spending a weekend wiring LSP, completion, fuzzy finder, treesitter, etc.

- LazyVim docs: <https://www.lazyvim.org/>
- LazyVim keymaps reference: <https://www.lazyvim.org/keymaps>
- LazyVim plugin extras catalog: <https://www.lazyvim.org/extras>
- Underlying plugin manager (lazy.nvim): <https://lazy.folke.io/>
- Neovim docs: `:help` inside nvim, or <https://neovim.io/doc/>

#### Custom plugins added on top of LazyVim

Files in `shared/.config/nvim/lua/plugins/`:

| File                  | Plugin / purpose                                                                                          |
|-----------------------|-----------------------------------------------------------------------------------------------------------|
| `lspconfig.lua`       | Custom gopls config tuned for the Urban Compass monorepo. **Self-disabling**: returns `{}` unless `~/development/urbancompass` exists, so other Macs keep LazyVim's default Go setup. See [Notable design decisions](#notable-design-decisions). |
| `editor.lua`          | [`telescope.nvim`](https://github.com/nvim-telescope/telescope.nvim) + [`telescope-fzf-native`](https://github.com/nvim-telescope/telescope-fzf-native.nvim) + [`telescope-file-browser`](https://github.com/nvim-telescope/telescope-file-browser.nvim), tuned for huge monorepos: ignores `bazel-*`, uses `fd` with custom excludes, max-filesize 1MB, smart-case rg search. Custom keymaps: `;f` find files, `;r` live grep, `;e` diagnostics, `sf` file browser. |
| `oil.lua`             | [`oil.nvim`](https://github.com/stevearc/oil.nvim) — edit your filesystem like a buffer. `-` opens parent dir. |
| `nvim-cmp.lua`        | [`blink.cmp`](https://github.com/Saghen/blink.cmp) preset, `Tab`/`Shift-Tab` for next/prev completion.    |
| `which-key.lua`       | [`which-key.nvim`](https://github.com/folke/which-key.nvim) in `modern` preset. Press `<space>` and pause to discover keymaps. |
| `conform.lua`         | [`conform.nvim`](https://github.com/stevearc/conform.nvim) format-on-save chain for markdown: prettier → markdownlint-cli2 → markdown-toc. |
| `coding.lua`          | [`inc-rename.nvim`](https://github.com/smjonas/inc-rename.nvim) — incremental LSP rename with live preview. |
| `colorscheme.lua`     | Loads [`tokyonight`](https://github.com/folke/tokyonight.nvim), [`solarized-osaka`](https://github.com/craftzdog/solarized-osaka.nvim) (transparent), and [`catppuccin`](https://github.com/catppuccin/nvim). |
| `ui.lua`              | Tweaks for [`noice.nvim`](https://github.com/folke/noice.nvim) (LSP doc borders, focus-aware notifications, markdown view) and [`nvim-notify`](https://github.com/rcarriga/nvim-notify) (5s timeout). |
| `mdx.lua`             | [`mdx.nvim`](https://github.com/davidmh/mdx.nvim) treesitter support for `.mdx` files.                    |

LazyVim extras enabled (in `shared/.config/nvim/lazyvim.json`):

- `lazyvim.plugins.extras.lang.markdown`

Custom keymaps in `shared/.config/nvim/lua/config/keymaps.lua`:

| Mode | Keys      | Action                                  |
|------|-----------|-----------------------------------------|
| n    | `<Space>w`| Save file                               |
| n    | `+` / `-` | Increment / decrement number under cursor |
| n    | `dw`      | Delete word backwards                   |
| n    | `<C-a>`   | Select all                              |
| n    | `<C-m>`   | Forward in jumplist                     |
| n    | `<C-j>`   | Next diagnostic                         |
| n    | `-`       | `:Oil` — open parent dir                |

Options (`shared/.config/nvim/lua/config/options.lua`):

- `vim.g.lazyvim_picker = "telescope"` — use Telescope, not Snacks picker
- `mouse = "a"` — mouse enabled in all modes

### Git TUI: lazygit

[**lazygit**](https://github.com/jesseduffield/lazygit) — terminal UI for git. Solves: muscle memory for `add/reset/stash/rebase/cherry-pick` without typing out commands.

Our config (`shared/.config/lazygit/config.yml`) is heavily tuned for huge monorepos:

- `pager: cat` (no [delta](https://github.com/dandavison/delta)) — delta can balloon to multi-GB rendering large diffs
- `refreshInterval: 60` (default 10) — much less work re-running plumbing on a 121k-file repo
- `fetchInterval: 300` (default 60) — auto-fetch every 5 min instead of 1
- `log.graph` without `--graph` and `--max-count=100` — drawing a graph over 196k commits / 20k branches is one of the heaviest ops
- `log.order: date-order` (cheaper than topo on big repos)
- `gui.showIcons: false` — no icon resolution per file in 121k-file tree
- `gui.showDivergenceFromBaseBranch: none` — no ahead/behind queries against 20k upstreams

Docs: <https://github.com/jesseduffield/lazygit#readme>
Keybindings: <https://github.com/jesseduffield/lazygit/blob/master/docs/keybindings/Keybindings_en.md>
Config reference: <https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md>

### AI assistant: OpenCode

[**OpenCode**](https://opencode.ai/) — terminal-native coding agent (open source).

What's in the repo:

| File                                                | What                                                                |
|-----------------------------------------------------|---------------------------------------------------------------------|
| `shared/.config/opencode/opencode-notifier.json`    | Config for the notifier plugin                                      |
| `shared/.config/opencode/package.json`              | Pins `@opencode-ai/plugin` for Bun                                  |
| `shared/.config/opencode/opencode.example.json`     | Template (without secrets) — copy to `opencode.json` and edit       |
| `work/.config/opencode/urbancompass-overrides.json` | UC-only overrides (snapshot off + watcher ignore list)              |

Plugin: [`@mohak34/opencode-notifier`](https://www.npmjs.com/package/@mohak34/opencode-notifier) — desktop notifications and audio cues when opencode needs you (permission ask, reply ready, error, question). Notification system set to `ghostty`, sound on, suppression off.

Docs: <https://opencode.ai/docs/>
Config reference: <https://opencode.ai/docs/config>
Plugins guide: <https://opencode.ai/docs/plugins>
GitHub: <https://github.com/anomalyco/opencode>

### CLI utilities: ripgrep, fd, bat, eza, gh

| Tool                                                              | What it replaces / why                                                |
|-------------------------------------------------------------------|-----------------------------------------------------------------------|
| [`ripgrep`](https://github.com/BurntSushi/ripgrep) (`rg`)         | Faster `grep`. Used by Telescope live-grep and most modern editors.   |
| [`fd`](https://github.com/sharkdp/fd)                             | Faster, friendlier `find`. Used by Telescope find-files.              |
| [`bat`](https://github.com/sharkdp/bat)                           | `cat` with syntax highlighting and git diff markers.                  |
| [`eza`](https://github.com/eza-community/eza)                     | Modern `ls` with icons / git status / tree view. Aliased in `config-osx.fish` to `ll` / `lla` if installed. |
| [`gh`](https://cli.github.com/)                                   | GitHub CLI. Used heavily by the OpenCode `addressing-pr-feedback` skill. |

---

## Work profile (Urban Compass-specific)

The `work/` profile only makes sense on a Mac that has the Compass monorepo at `~/development/urbancompass`. Everything in `shared/` is designed to also work without that directory.

| Path                                              | What it does                                                                                                        |
|---------------------------------------------------|---------------------------------------------------------------------------------------------------------------------|
| `.config/fish/conf.d/urbancompass.fish`           | Sets `UC_REPO_ROOT`, defines `ncuc` / `ncuc_module` aliases, hooks `compass` autocomplete, wires `jenv`, exports MDM CA bundle env vars (`AWS_CA_BUNDLE`, `NODE_EXTRA_CA_CERTS`, `CURL_CA_BUNDLE`, `REQUESTS_CA_BUNDLE`, `SSL_CERT_FILE`). Auto-loaded by fish from `conf.d/` after `config.fish`. |
| `.config/fish/functions/oc.fish`                  | Defines `oc` — a wrapper around `opencode` that, when `pwd` is inside the monorepo, sets `OPENCODE_CONFIG=~/.config/opencode/urbancompass-overrides.json` so the override is layered on top of the project config. Outside the monorepo it's a transparent passthrough to `opencode`. |
| `.config/opencode/urbancompass-overrides.json`    | Disables snapshots (`snapshot: false`) and adds a watcher ignore list (`bazel-*/**`, `node_modules/**`, `src/go/compass.com/**/mocks/**`, `build-support/go/pkg/**`, etc.) so the "Modified Files" list in opencode doesn't blow up from background Bazel/mock generation. |

**Always launch opencode at work via `oc`, not `opencode`.** Same outside the monorepo, only different inside.

---

## Cutover on a working machine

If your machine already has real config files in `~/.config/`, you don't have to do the whole cutover at once. Use `bin/cutover-incremental.sh` to migrate **one tool at a time**, with automatic backup and rollback:

```bash
# List what's available in a profile
bin/cutover-incremental.sh --list shared

# Migrate one tool (the previous file becomes <name>.preinstall.bak)
bin/cutover-incremental.sh shared lazygit
bin/cutover-incremental.sh shared ghostty
bin/cutover-incremental.sh shared starship.toml

# Migrate just one file inside a directory (use this when the directory contains
# both repo-managed and purely local files, e.g. opencode/opencode.json with secrets)
bin/cutover-incremental.sh shared opencode/opencode-notifier.json
bin/cutover-incremental.sh work opencode/urbancompass-overrides.json

# Rollback if something breaks
bin/cutover-incremental.sh --rollback shared lazygit
```

Each cutover is reversible until you delete the `.preinstall.bak` file. Once you've validated everything for a few days, free up space:

```bash
find ~/.config -name "*.preinstall.bak" -exec rm -rf {} +
```

---

## Secrets handling

The following files are **gitignored** and never make it to GitHub:

| File                                                              | Why                                                                                              |
|-------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| `~/.config/opencode/opencode.json`                                | Contains Onyx MCP gateway API keys, Obsidian API key, Fireworks-AI baseURL with embedded token   |
| `~/.config/opencode/opencode-notifier-state.json`                 | Runtime state                                                                                    |
| `~/.config/fish/fish_variables`                                   | Fish universal variables (per-machine state)                                                     |
| `~/.config/lazygit/state.yml`                                     | Lazygit runtime state                                                                            |
| `~/.config/opencode/{node_modules,bun.lock,package-lock.json}`    | Runtime artifacts; reinstalled by Bun on first opencode launch                                   |
| Anything matching `*.local`, `*.private`, `.env`, `*.token`       | Generic secret patterns                                                                          |

After install, copy the OpenCode example config and fill in your own values:

```bash
cp ~/.config/opencode/opencode.example.json ~/.config/opencode/opencode.json
$EDITOR ~/.config/opencode/opencode.json
```

---

## Notable design decisions

- **`gopls` config has a directory guard.** `shared/.config/nvim/lua/plugins/lspconfig.lua` returns `{}` unless `~/development/urbancompass` exists. So on a non-Compass Mac you get LazyVim's default Go setup; on a Compass Mac you get the memory-optimized one (`memoryMode = "DegradeClosed"`, `expandWorkspaceToModule = false`, `staticcheck = false`, `completeUnimported = false`, custom `directoryFilters` excluding `bazel-*`) that prevents gopls from eating ~15 GB indexing the 474-package monorepo.

- **`oc` instead of `opencode` at work.** The `oc` fish function checks if `pwd` is inside `~/development/urbancompass`. If so, it sets `OPENCODE_CONFIG=~/.config/opencode/urbancompass-overrides.json` and merges `snapshot=false` + watcher ignores on top of the project's `.ai/opencode.json`. Outside the monorepo, `oc` runs vanilla opencode. This avoids touching the version-controlled config that's shared with the whole team.

- **Lazygit pager is `cat`, not `delta`.** On a 121k-file / 196k-commit monorepo, delta can balloon to multi-GB rendering large diffs.

- **`XDG_CONFIG_HOME` is set explicitly in `config.fish`.** Without it, lazygit on macOS reads from `~/Library/Application Support/lazygit/` instead of `~/.config/lazygit/`, silently ignoring our config.

- **Fish plugins are NOT vendored.** `tide`, `nvm.fish`, `bass` are reinstalled via fisher on first run — only `fish_plugins` (the manifest) is committed.

- **`lazy-lock.json` IS committed.** Pins LazyVim plugin versions across machines so a fresh clone gets the exact same plugin tree.

- **No `.stowrc`.** Past experience showed that `--target=$HOME --dir=$PWD` in `.stowrc` interacts badly with explicit `--target` on the command line (stow silently skips directories). We pass flags explicitly in `install.sh` instead.

---

## Learning resources

A curated list of resources for the tools used here, organized from "I want to learn the basics" to "I want to go deep".

### Vim / Neovim

If you've never used vim before, start with `vimtutor` (`:Tutor` in nvim) — it's a 30-minute interactive lesson that ships with vim and teaches the modal editing mindset.

**Interactive learning**

- [**OpenVim**](https://www.openvim.com/) — interactive in-browser vim tutorial. Great for the absolute basics.
- [**Vim Adventures**](https://vim-adventures.com/) — learn vim by playing a Zelda-like game. First few levels free, the rest are paid but worth it.
- [**Vim Genius**](http://www.vimgenius.com/) — flashcard-style vim drills to build muscle memory.
- [**Vimcasts**](http://vimcasts.org/) — short screencasts on specific vim techniques (older but timeless).
- [**`:help`**](https://neovim.io/doc/user/) — the built-in docs are *the* reference. `:help motion`, `:help text-objects`, `:help registers` are gold.

**Books and long reads**

- [**Practical Vim** by Drew Neil](https://pragprog.com/titles/dnvim2/practical-vim-second-edition/) — the canonical book. Worth every penny.
- [**Modern Vim** by Drew Neil](https://pragprog.com/titles/modvim/modern-vim/) — sequel covering vim 8 / Neovim, terminal mode, async jobs, plugin patterns.
- [**Learn Vim (the Smart Way)**](https://github.com/iggredible/Learn-Vim) — free, open-source book.
- [**Mastering Vim Quickly**](https://masteringvim.com/) — short and practical.

**LazyVim specifically**

- [LazyVim docs](https://www.lazyvim.org/) — start here for the framework.
- [LazyVim keymaps](https://www.lazyvim.org/keymaps) — what each `<leader>` mapping does out of the box.
- [LazyVim extras](https://www.lazyvim.org/extras) — curated catalog of language packs and integrations to enable in `lazyvim.json`.
- [TJ DeVries — LazyVim from scratch](https://www.youtube.com/watch?v=N93cTbtLCIM) — video walkthrough.
- [folke's videos](https://www.youtube.com/@folke_io) — author of LazyVim, plenty of tips.

**Plugin discovery**

- [Awesome Neovim](https://github.com/rockerBOO/awesome-neovim) — huge curated plugin index.
- [Dotfyle](https://dotfyle.com/) — neovim plugin trends and configs.
- [`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter), [`nvim-lspconfig`](https://github.com/neovim/nvim-lspconfig), [`mason.nvim`](https://github.com/williamboman/mason.nvim) — the foundation everyone builds on.

### Fish shell

- [Fish official tutorial](https://fishshell.com/docs/current/tutorial.html) — the fastest way in.
- [Fish docs](https://fishshell.com/docs/current/) — `man fish-tutorial`, `man fish-language`, etc., are also installed locally.
- [Cookbook for fish](https://github.com/jorgebucaran/cookbook.fish) — recipes for common shell tasks.
- [Fisher plugin index](https://github.com/jorgebucaran/awesome.fish) — curated list of plugins.
- [Tide configurator](https://github.com/IlanCosman/tide#configuration) — `tide configure` walks you through prompt setup interactively.

### Lazygit & git

- [Lazygit docs](https://github.com/jesseduffield/lazygit#readme)
- [Keybindings cheatsheet](https://github.com/jesseduffield/lazygit/blob/master/docs/keybindings/Keybindings_en.md)
- [Git Pro book](https://git-scm.com/book/en/v2) — the canonical git reference, free online.
- [Oh My Git!](https://ohmygit.org/) — visual game for learning git internals.
- [Learn Git Branching](https://learngitbranching.js.org/) — interactive in-browser tutorial.

### General terminal productivity

- [`fzf` examples wiki](https://github.com/junegunn/fzf/wiki/Examples) — endless tricks for the fuzzy finder.
- [Modern Unix](https://github.com/ibraheemdev/modern-unix) — curated list of modern alternatives to old Unix tools (rg, fd, bat, eza, etc.).
- [The Art of Command Line](https://github.com/jlevy/the-art-of-command-line) — pragmatic shell tips.
- [`tldr`](https://tldr.sh/) — community-driven, simplified man pages. `brew install tldr`, then `tldr tar`.

---

## License

[MIT](./LICENSE)
