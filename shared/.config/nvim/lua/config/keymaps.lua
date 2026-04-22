-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- save file changes with space+w
keymap.set("n", "<Space>w", "<cmd>w<cr>")

-- increment and decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- keymap.set("n", "<leader>c", "<cmd>:bd<cr>")
-- delete a word backwards
keymap.set("n", "dw", "vb_d")

-- select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- jumplist
keymap.set("n", "<C-m>", "<C-i>", opts)

-- Diagnostic
keymap.set("n", "<C-j>", function()
  vim.diagnostic.goto_next()
end)

keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
