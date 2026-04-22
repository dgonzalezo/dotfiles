-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.filetype.add({
  extension = {
    mdx = "mdx",
  },
})

-- Load local .nvimrc.lua if it exists (for per-project configuration)
-- This enables optimizations for large monorepos like Urban Compass
local nvimrc = vim.fn.findfile(".nvimrc.lua", ".;")
if nvimrc ~= "" then
  vim.cmd.source(nvimrc)
end
