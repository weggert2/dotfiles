vim.opt.termguicolors=true
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.clipboard = "unnamedplus"

vim.opt.expandtab = true        -- Use spaces instead of tabs
vim.opt.tabstop = 4             -- 1 tab == 4 spaces
vim.opt.shiftwidth = 4          -- Indent width
vim.opt.softtabstop = 4         -- Backspace/delete treats 4 spaces as a tab
vim.opt.smartindent = true      -- Auto-indent new lines
vim.opt.splitright = true

vim.opt.number = true           -- Absolute line number for the current line
vim.opt.relativenumber = true   -- Relative line numbers for all others

vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.cindent = true

require("config.keymaps")
require("config.lazy")
require("config.commands")
require("config.autocmds")
require("config.colors").setup()

-- Set :make to run the CMake build step
vim.opt.makeprg = "cmake --build build --parallel $(nproc)"

-- Set the error format for parsing compiler errors (gcc/clang-style)
vim.opt.errorformat = "%f:%l:%c: %t%*[^:]: %m"

vim.filetype.add {
    extension = {
        zsh = "bash",
    }
}

-- Visual Multi color setup. Must come last. Don't put in colors.lua, it doesn't
-- work for some reason

-- 1. Define color palette
local orange_bg = "#ff9e3b"
local orange_fg = "#223249"
local soft_orange = "#ffb347"
local golden_orange = "#ffae5f"
local selection_orange = "#ffd392"
local active_cursor_bg = "#ffa733"  -- slightly brighter than #ff9e3b

-- 2. Set highlight groups for visual-multi
vim.api.nvim_set_hl(0, "VM_Mono", {
    bg = orange_bg,
    fg = orange_fg,
    bold = true,
})

vim.api.nvim_set_hl(0, "VM_Cursor", {
    bg = orange_bg,
    fg = orange_fg,
    bold = true,
})

vim.api.nvim_set_hl(0, "VM_Insert", {
    bg = golden_orange,
    fg = orange_fg,
    bold = true,
})

vim.api.nvim_set_hl(0, "VM_Extend", {
    bg = soft_orange,
    fg = orange_fg,
    bold = true,
})

vim.api.nvim_set_hl(0, "VM_Selection", {
    bg = selection_orange,
    fg = orange_fg,
})

-- 3. Handle real cursor: orange during VM, default outside
local function set_cursor_to_vm_style()
    vim.opt.guicursor = "n-v-c:block-Cursor" -- Ensure cursor highlight is used
    vim.api.nvim_set_hl(0, "Cursor", {
        bg = "#ffb84d",
        fg = "#1a1a1a",
        bold = true,
    })
end

local function set_cursor_to_theme_default()
    vim.api.nvim_set_hl(0, "Cursor", { reverse = true }) -- Kanagawa-style
end

-- 4. Autocommands for entering/exiting VM mode
vim.api.nvim_create_autocmd("User", {
    pattern = "visual_multi_start",
    callback = set_cursor_to_vm_style,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "visual_multi_exit",
    callback = set_cursor_to_theme_default,
})


