vim.opt.termguicolors=true
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.clipboard = "unnamedplus"
vim.o.shell = "/bin/zsh"
vim.opt.signcolumn = "yes"

vim.opt.expandtab = true        -- Use spaces instead of tabs
vim.opt.tabstop = 4             -- 1 tab == 4 spaces
vim.opt.shiftwidth = 4          -- Indent width
vim.opt.softtabstop = 4         -- Backspace/delete treats 4 spaces as a tab
vim.opt.smartindent = true      -- Auto-indent new lines
vim.opt.splitright = true
vim.opt.scrolloff = 10
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

vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

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
            -- Compiler errors (with column)
            "%f:%l:%c: %t%*[^:]: %m",

            -- Compiler errors (no column)
            "%f:%l: %t%*[^:]: %m",

            -- Makefile target errors
            "%f:%l: %m",
            "make[%*\\d]: *** %m",
            "gmake[%*\\d]: *** %m",
            "make: *** %m",
            "gmake: *** %m",

            -- Linker errors
            "collect2: %m",
            "/usr/bin/ld: %m",

            -- Filter out everything else
            "%-G%.%#",
        }, ",")
    end,
})

vim.filetype.add {
    extension = {
        zsh = "bash",
    }
}

