# dotfiles

macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/), organized into three composable profiles: `shared`, `personal`, and `work`.

> **Note**: this repo was previously a Linux dotfiles collection (bspwm / polybar / sxhkd / etc.). That history is preserved in the [`archive/linux-2022`](https://github.com/dgonzalezo/dotfiles/tree/archive/linux-2022) branch.

## Profiles

| Profile    | Contents                                                                    |
|------------|-----------------------------------------------------------------------------|
| `shared/`  | Tools used on every Mac (fish, neovim, lazygit, ghostty, starship, opencode base config, notifier plugin) |
| `personal/`| Personal-Mac-only configs                                                   |
| `work/`    | Work-Mac-only configs (Urban Compass overrides, `oc` fish wrapper)          |

Profiles are stowed independently — combine them as needed:

- **Personal Mac**: `shared` + `personal`
- **Work Mac**: `shared` + `work`
- **Someone else cloning**: `shared` only

## Quick Start

```bash
git clone https://github.com/dgonzalezo/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh shared work    # or: shared personal, or just shared
```

The installer will:
1. Install Homebrew dependencies (stow, fish, neovim, lazygit, ghostty, starship, ripgrep, fd, bat, eza, fzf, gh, zoxide).
2. Run `stow` for each requested profile.
3. Print post-install steps (chsh to fish, open nvim once for Lazy sync, open opencode once so Bun installs the notifier plugin).

## What's NOT included

Secrets are deliberately excluded via `.gitignore`:

- `~/.config/opencode/opencode.json` (Onyx MCP gateway keys, Obsidian API key)
- `~/.config/opencode/opencode-notifier-state.json` (runtime state)
- SSH keys, GPG keys, AWS credentials
- Fish runtime variables, lazygit state

After install, copy the example configs and fill in your own keys (see `docs/SECRETS.md`, TODO).

## Structure

```
~/.dotfiles/
├── shared/
│   └── .config/
│       ├── fish/
│       ├── nvim/
│       ├── lazygit/
│       ├── ghostty/
│       ├── starship.toml
│       └── opencode/
│           ├── opencode-notifier.json
│           └── package.json
├── personal/
│   └── .config/
│       └── (TBD)
├── work/
│   └── .config/
│       ├── fish/functions/oc.fish
│       └── opencode/urbancompass-overrides.json
├── install.sh
├── .stowrc
├── .gitignore
└── README.md
```

## License

MIT — see [LICENSE](./LICENSE).
