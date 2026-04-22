return {
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      explorer = {},
      -- Disable snacks picker
      picker = {
        enabled = false,
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
            win = {
              list = {
                keys = {
                  ["M"] = "toggle_maximize",
                },
              },
            },
          },
        },
      },
      -- Configure terminal to be floating
      terminal = {
        win = {
          position = "float",
        },
      },
      -- Configure lazygit for large monorepos
      lazygit = {
        theme_path = vim.fn.stdpath("cache") .. "/lazygit-theme.yml",
        config = {
          -- Disable auto-fetch for large repos (improves performance)
          git = {
            autoFetch = false,
            autoRefresh = false,
            fetchInterval = 120, -- Check every 2 minutes instead of 60 seconds
          },
          -- Disable auto-forward branches for large repos
          autoForwardBranches = "none",
          -- Optimize for large repositories
          os = {
            editPreset = "nvim-remote",
          },
          gui = {
            nerdFontsVersion = "3",
          },
        },
      },
    },
    keys = {
      -- Terminal at current file's directory
      {
        "<c-/>",
        function()
          Snacks.terminal(nil, { cwd = vim.fn.getcwd() })
        end,
        desc = "Terminal (file dir)",
        mode = { "n" },
      },
      {
        "<c-/>",
        "<cmd>close<cr>",
        desc = "Hide Terminal",
        mode = { "t" },
      },
      -- Explorer at Current Working Directory (CWD)
      {
        "<leader>e",
        function()
          Snacks.explorer({ cwd = vim.fn.getcwd() })
        end,
        desc = "Explorer (CWD)",
      },
      -- Explorer at Git Root
      {
        "<leader>E",
        function()
          -- Find git root directory
          local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
          if vim.v.shell_error == 0 and git_root ~= "" then
            Snacks.explorer({ cwd = git_root, reveal = true })
          else
            -- Fallback to home directory if not in a git repo
            Snacks.explorer({ cwd = vim.fn.expand("~"), reveal = true })
          end
        end,
        desc = "Explorer (Git Root)",
      },
    },
  },
}
