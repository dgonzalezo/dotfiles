--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]
-- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT

-- general
lvim.log.level = "warn"
lvim.format_on_save = false
lvim.colorscheme = "onedarker"

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.builtin.which_key.mappings["r"] = { ":RnvimrToggle<CR>", "Ranger" }
lvim.builtin.which_key.mappings["nn"] = { ":!tmux neww ~/.local/bin/cheat.sh<CR>", "Cheat" }
lvim.builtin.which_key.mappings["htf"] = { ":!prettier --write %<CR><CR><CR>", "html format" }
lvim.builtin.which_key.mappings["o"] = { "<cmd>SymbolsOutline<cr>", "Outline" }
lvim.builtin.which_key.mappings["lR"] = { ":LspRestart<cr>", "Lsp restart" }
lvim.lsp.diagnostics.virtual_text = false

-- Use which-key to add extra bindings with the leader-key prefix
lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
lvim.builtin.which_key.mappings["t"] = {
	name = "+Trouble",
	r = { "<cmd>Trouble lsp_references<cr>", "References" },
	f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
	d = { "<cmd>Trouble lsp_document_diagnostics<cr>", "Diagnostics" },
	q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
	l = { "<cmd>Trouble loclist<cr>", "LocationList" },
	w = { "<cmd>Trouble lsp_workspace_diagnostics<cr>", "Diagnostics" },
}

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.dashboard.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.side = "left"
lvim.builtin.nvimtree.show_icons.git = 1
lvim.builtin.dap.active = true

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = "maintained"
lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true
lvim.lsp.automatic_servers_installation = true

-- generic LSP settings
-- you can set a custom on_attach function that will be used for all the language servers
-- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end
-- you can overwrite the null_ls setup table (useful for setting the root_dir function)
-- lvim.lsp.null_ls.setup = {
--   root_dir = require("lspconfig").util.root_pattern("Makefile", ".git", "node_modules"),
-- }
-- or if you need something more advanced
-- lvim.lsp.null_ls.setup.root_dir = function(fname)
--   if vim.bo.filetype == "javascript" then
--     return require("lspconfig/util").root_pattern("Makefile", ".git", "node_modules")(fname)
--       or require("lspconfig/util").path.dirname(fname)
--   elseif vim.bo.filetype == "php" then
--     return require("lspconfig/util").root_pattern("Makefile", ".git", "composer.json")(fname) or vim.fn.getcwd()
--   else
--     return require("lspconfig/util").root_pattern("Makefile", ".git")(fname) or require("lspconfig/util").path.dirname(fname)
--   end
-- end

-- set a formatter if you want to override the default lsp one (if it exists)
vim.list_extend(lvim.lsp.override, { "pyright" })
vim.list_extend(lvim.lsp.override, { "emmet_ls" })
vim.api.nvim_command("set relativenumber")
vim.api.nvim_command("set guicursor=n:blinkon0")

vim.cmd("let g:user_emmet_leader_key='<C-Z>'")

require("lvim.lsp.manager").setup("sumneko_lua")

-- formatters
local formatters = require "lvim.lsp.null-ls.formatters"

formatters.setup {
  { exe = "black", filetypes = { "python" } },
  {
    exe = "prettier",
    args = { "--print-width", "100" },
    filetypes = { "typescript", "javascript", "vue", "html", "typescriptreact" },
  },
  -- {
    -- exe = "stylua",
    -- filetypes = { "lua" }
  -- },
  { exe = "clang_format", filetypes = {"c", "cpp"}}
}

-- linters
local linters = require "lvim.lsp.null-ls.linters"

linters.setup {
  { exe = "flake8" },
  {
    exe = "eslint",
    filetypes = { "typescript", "javascript", "vue", "html", "typescriptreact" },
  }
}

lvim.lang.ruby.host = "127.0.0.1"
lvim.lang.ruby.port = "1234"

local dap_install = require("dap-install")
dap_install.config("ruby_vsc", {
	-- adapters = {
	-- 	args = { "--skip_wait_for_start" },
	-- },
	configurations = {
		{
			type = "ruby",
			request = "attach",
			name = "Debug Attach",
			cwd = "${workspaceFolder}",
			remoteWorkspaceFolder = "${workspaceFolder}",
			remoteHost = lvim.lang.ruby.host,
			remotePort = lvim.lang.ruby.port,
			-- program = "bundle",
			-- programArgs = { "exec", "${workspaceFolder}/bin/rails", "server" },
			-- useBundler = true,
		},
	},
})
-- local dap = require('dap')
--     dap.adapters.chrome = {
--       -- executable: launch the remote debug adapter - server: connect to an already running debug adapter    
--       type = "executable",
--       -- command to launch the debug adapter - used only on executable type    
--       command = "node",
--       args = { os.getenv("HOME") .. "/elian/Documents/Trabajo/dev/vscode-chrome-debug/out/src/chromeDebug.js" }
--     }
--     -- The configuration must be named: typescript    
--     dap.configurations.javascript = {
--       {
--         name = "Debug (Attach) - Remote",
--         type = "chrome",
--         request = "attach",
--         -- program = "${file}",    
--         -- cwd = vim.fn.getcwd(),    
--         sourceMaps = true,
--         --      reAttach = true,    
--         trace = true,
--         -- protocol = "inspector",    
--         -- hostName = "127.0.0.1",    
--         port = 9222,
--         webRoot = "${workspaceFolder}"
--       }
--     }
-- Additional Plugins
lvim.plugins = {
	{ "folke/tokyonight.nvim" },
	{
		"folke/trouble.nvim",
		cmd = "TroubleToggle",
	},
	{
		"tpope/vim-rails",
		cmd = {
			"Eview",
			"Econtroller",
			"Emodel",
			"Smodel",
			"Sview",
			"Scontroller",
			"Vmodel",
			"Vview",
			"Vcontroller",
			"Tmodel",
			"Tview",
			"Tcontroller",
			"Rails",
			"Generate",
			"Runner",
			"Extract",
		},
	},

	{ "theHamsta/nvim-dap-virtual-text" },
	{ "rcarriga/nvim-dap-ui" },
	{ "kevinhwang91/rnvimr" },
  {
    "mattn/emmet-vim",
    ft = { "html", "css", "eruby", "javascript" },
  },
  {
			"simrat39/symbols-outline.nvim",
			cmd = "SymbolsOutline",
  },
  {
			"norcalli/nvim-colorizer.lua",
			config = function()
				require("colorizer").setup({ "*" }, {
					RGB = true, -- #RGB hex codes
					RRGGBB = true, -- #RRGGBB hex codes
					RRGGBBAA = true, -- #RRGGBBAA hex codes
					rgb_fn = true, -- CSS rgb() and rgba() functions
					hsl_fn = true, -- CSS hsl() and hsla() functions
					css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
					css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
				})
			end,
		},
  {
			"phaazon/hop.nvim",
			as = "hop",
      keys = {"s"},
			config = function()
				-- you can configure Hop the way you like here; see :h hop-config
				require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })
				vim.api.nvim_set_keymap("n", "s", ":HopWord<cr>", {})
			end,
		},
}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- lvim.autocommands.custom_groups = {
--   { "BufWinEnter", "*.lua", "setlocal ts=8 sw=8" },
-- }
