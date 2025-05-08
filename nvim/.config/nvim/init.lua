vim.opt.termguicolors=true
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.clipboard = "unnamedplus"
vim.o.shell = "/bin/zsh"

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
vim.opt.fixendofline = true

vim.opt.list = true
vim.opt.listchars = {
    -- space = "·",     -- dot for space
    tab = "▸ ",      -- arrow + space for tab
    trail = "•",     -- bullet for trailing space
    extends = "⟩",   -- when line overflows right
    precedes = "⟨",  -- when line overflows left
}

require("config.keymaps")
require("config.lazy")
require("config.commands")
require("config.autocmds")
require("config.colors").setup()

-- Pick a build system based on whether we have CMake, Make, or nothing
-- Applies to C/C++
vim.api.nvim_create_autocmd("FileType", {
    pattern = {
        "c", "cpp", "cc", "cxx",
        "h", "hh", "hpp", "hxx",
        "objc", "objcpp",
        "tpp", "ipp", "inl", "ixx"
    },
    callback = function()
        local fname = vim.fn.expand("%:p")
        local ext = vim.fn.expand("%:e")
        local output = vim.fn.expand("%:r")
        local fallback = ""

        -- Check for CMakeLists.txt
        local has_cmake = vim.fn.filereadable("CMakeLists.txt") == 1

        -- Check for any common makefile naming
        local makefiles = { "Makefile", "makefile", "GNUMakefile" }
        local has_makefile = false
        for _, f in ipairs(makefiles) do
            if vim.fn.filereadable(f) == 1 then
                has_makefile = true
                break
            end
        end

        if has_cmake then
            fallback = table.concat({
                "cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTS=ON -DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
                "cmake --build build --parallel $(nproc)"
            }, " && ")
        elseif has_makefile then
            fallback = "make"
        else
            local compiler = (ext == "c") and "gcc" or "g++"
            fallback = string.format("%s -g %s -o %s", compiler, fname, output)
        end

        vim.opt_local.makeprg = fallback

        vim.opt_local.errorformat = table.concat({
            "%f:%l:%c: %t%*[^:]: %m",
            "%f:%l: %t%*[^:]: %m",
            "%-G%.%#",
        }, ",")
    end,
})

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


