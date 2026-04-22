-- =============================================================================
-- gopls overrides for the Urban Compass monorepo
-- =============================================================================
-- This file ONLY applies its overrides on machines that have the Urban Compass
-- monorepo cloned at ~/development/urbancompass. On any other machine it
-- returns an empty plugin spec, leaving LazyVim's default gopls behavior intact.
--
-- Without these overrides, gopls eats ~15 GB of RAM trying to index the
-- ~474 Go packages under src/go/compass.com/.
-- =============================================================================

local repo_root = vim.fn.expand("~/development/urbancompass")

-- Guard: bail out if the monorepo isn't present on this machine.
if vim.fn.isdirectory(repo_root) ~= 1 then
  return {}
end

local go_sdk = repo_root .. "/build-support/go/sdk"
local gopath = repo_root .. "/build-support/go"
local gomodcache = gopath .. "/pkg/mod"

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      diagnostics = {
        virtual_text = false,
        signs = true,
        underline = true,
        update_in_insert = false,
      },
      -- Use LazyVim's opts.servers pattern so LazyVim manages setup correctly
      servers = {
        gopls = {
          -- Urban Compass: go.work is at repo root (~urbancompass/).
          -- The new vim.lsp.config() API uses root_markers (not root_dir function).
          -- Use ONLY "go.work" so it resolves to the repo root, not to
          -- src/go/compass.com/ where go.mod lives (which would cause -mod=mod conflict).
          root_markers = { "go.work" },
          cmd_env = {
            GOROOT = go_sdk,
            GOPATH = gopath,
            GOMODCACHE = gomodcache,
            -- Explicitly point to go.work so gopls uses workspace mode (not -mod=mod)
            GOWORK = repo_root .. "/go.work",
            PATH = go_sdk .. "/bin:" .. vim.env.PATH,
            GOPROXY = "https://artifacts.compass-tech.net/repository/go",
            CGO_ENABLED = "1",
          },
          settings = {
            gopls = {
              buildFlags = { "-tags=integration" },
              hoverKind = "FullDocumentation",
              -- Memory optimizations for large monorepo (~474 Go packages)
              -- Frees memory for packages no longer open in any buffer
              memoryMode = "DegradeClosed",
              -- Don't expand workspace to the full Go module when opening a single file.
              -- This prevents gopls from loading all 474 packages just because you opened
              -- one file inside src/go/compass.com/.
              expandWorkspaceToModule = false,
              -- Disabled: staticcheck is CPU/memory expensive on large repos.
              -- Run it manually with `staticcheck ./...` when needed.
              staticcheck = false,
              -- Disabled: forces gopls to index all unimported packages in the workspace
              -- to offer them as completions. Very expensive in this monorepo.
              -- goimports (run on save by LazyVim's conform.lua) compensates for the
              -- loss of "auto-import unimported package" completions.
              completeUnimported = false,
              usePlaceholders = true,
              symbolMatcher = "fuzzy",
              -- Extend LazyVim's default directoryFilters with Bazel-specific exclusions
              directoryFilters = {
                "-bazel-bin",
                "-bazel-out",
                "-bazel-testlogs",
                "-bazel-urbancompass",
                "-.git",
                "-.vscode",
                "-.idea",
                "-node_modules",
              },
            },
          },
        },
      },
    },
  },
}
