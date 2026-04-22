-- plugins/editor.lua: Telescope configuration optimized for large monorepos
return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "v0.2.0",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        config = function()
          require("telescope").load_extension("fzf")
        end,
      },
      "nvim-telescope/telescope-file-browser.nvim",
    },
    keys = {
      -- Find files in CWD
      {
        ";f",
        function()
          local builtin = require("telescope.builtin")
          builtin.find_files({
            cwd = vim.fn.getcwd(),
            no_ignore = false,
            hidden = true,
          })
        end,
        desc = "Find files (CWD)",
      },
      -- Find files in Git Root
      {
        ";F",
        function()
          local builtin = require("telescope.builtin")
          builtin.find_files({
            no_ignore = false,
            hidden = true,
          })
        end,
        desc = "Find files (Git Root)",
      },
      -- Live grep in CWD
      {
        ";r",
        function()
          local builtin = require("telescope.builtin")
          builtin.live_grep({
            cwd = vim.fn.getcwd(),
            additional_args = { "--hidden" },
          })
        end,
        desc = "Live grep (CWD)",
      },
      -- Live grep in Git Root
      {
        ";R",
        function()
          local builtin = require("telescope.builtin")
          builtin.live_grep({
            additional_args = { "--hidden" },
          })
        end,
        desc = "Live grep (Git Root)",
      },
      {
        "\\\\",
        function()
          local builtin = require("telescope.builtin")
          builtin.buffers()
        end,
        desc = "Lists open buffers",
      },
      {
        ";t",
        function()
          local builtin = require("telescope.builtin")
          builtin.help_tags()
        end,
        desc = "Lists available help tags and opens a new window with the relevant help info on <cr>",
      },
      {
        ";;",
        function()
          local builtin = require("telescope.builtin")
          builtin.resume()
        end,
        desc = "Resume the previous telescope picker",
      },
      {
        ";e",
        function()
          local builtin = require("telescope.builtin")
          builtin.diagnostics()
        end,
        desc = "Lists Diagnostics for all open buffers or a specific buffer",
      },
      {
        ";s",
        function()
          local builtin = require("telescope.builtin")
          builtin.treesitter()
        end,
        desc = "Lists Function names, variables, from Treesitter",
      },
      {
        "sf",
        function()
          local telescope = require("telescope")

          local function telescope_buffer_dir()
            return vim.fn.expand("%:p:h")
          end

          telescope.extensions.file_browser.file_browser({
            path = "%:p:h",
            cwd = telescope_buffer_dir(),
            respect_gitignore = false,
            hidden = true,
            grouped = true,
            previewer = false,
            initial_mode = "normal",
            layout_config = { height = 40 },
          })
        end,
        desc = "Open File Browser with the path of the current buffer",
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local fb_actions = require("telescope").extensions.file_browser.actions

      -- Optimized for large monorepos
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--max-columns=200",
          "--max-filesize=1M",
        },
        wrap_results = true,
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top", preview_width = 0.5 },
        sorting_strategy = "ascending",
        winblend = 0,
        file_ignore_patterns = {
          "bazel-bin",
          "bazel-out",
          "bazel-testlogs",
          "bazel-urbancompass",
          ".bazelcache",
          ".git",
          "node_modules",
          "vendor",
          ".idea",
          "%.swp",
          "%.swo",
          "dist",
          "build",
        },
        mappings = {
          n = {},
        },
      })

      opts.pickers = {
        find_files = {
          find_command = {
            "fd",
            "--type",
            "f",
            "--strip-cwd-prefix",
            "--hidden",
            "--exclude",
            ".git",
            "--exclude",
            "bazel-*",
            "--exclude",
            "node_modules",
            "--exclude",
            "vendor",
            "--exclude",
            ".bazelcache",
            "--exclude",
            ".idea",
          },
          follow = true,
          hidden = true,
        },
        diagnostics = {
          theme = "ivy",
          initial_mode = "normal",
          layout_config = {
            preview_cutoff = 9999,
          },
        },
        live_grep = {
          only_sort_text = true,
          max_results = 1000,
        },
      }

      opts.extensions = {
        file_browser = {
          theme = "dropdown",
          -- disables netrw and use telescope-file-browser in its place
          hijack_netrw = true,
          mappings = {
            -- your custom insert mode mappings
            ["n"] = {
              -- your custom normal mode mappings
              ["N"] = fb_actions.create,
              ["h"] = fb_actions.goto_parent_dir,
              ["/"] = function()
                vim.cmd("startinsert")
              end,
              ["<C-u>"] = function(prompt_bufnr)
                for i = 1, 10 do
                  actions.move_selection_previous(prompt_bufnr)
                end
              end,
              ["<C-d>"] = function(prompt_bufnr)
                for i = 1, 10 do
                  actions.move_selection_next(prompt_bufnr)
                end
              end,
              ["<PageUp>"] = actions.preview_scrolling_up,
              ["<PageDown>"] = actions.preview_scrolling_down,
            },
          },
        },
      }
      telescope.setup(opts)
      require("telescope").load_extension("fzf")
      require("telescope").load_extension("file_browser")
    end,
  },
}
