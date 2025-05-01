vim.opt.termguicolors=true
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.clipboard = "unnamedplus"

vim.opt.expandtab = true        -- Use spaces instead of tabs
vim.opt.tabstop = 4             -- 1 tab == 4 spaces
vim.opt.shiftwidth = 4          -- Indent width
vim.opt.softtabstop = 4         -- Backspace/delete treats 4 spaces as a tab
vim.opt.smartindent = true      -- Auto-indent new lines

vim.opt.number = true           -- Absolute line number for the current line
vim.opt.relativenumber = true   -- Relative line numbers for all others

vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.cindent = true

require("config.keymaps")
require("config.lazy")
require("config.commands")

