require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "lua", "cpp", "c", "bash", "python", "vim", "markdown", "rust", "zig", "cmake",
    },
    highlight = {
        enable = true,
    },
    indent = {
        enable = true,
        disable = { "cpp", "c" }, -- use cindent for these
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<CR>",
            node_incremental = "<CR>",
            node_decremental = "<BS>",
        },
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            disable = { "vim", "make", "query", "bash", "markdown", "gitcommit" },
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
                ["aa"] = "@parameter.outer",
                ["ia"] = "@parameter.inner",
                ["ab"] = "@block.outer",
                ["ib"] = "@block.inner",
                ["aC"] = "@conditional.outer",
                ["iC"] = "@conditional.inner",
                ["al"] = "@loop.outer",
                ["il"] = "@loop.inner",
                ["aC"] = "@call.outer",
                ["iC"] = "@call.inner",
            },
        },
        move = {
            enable = true,
            set_jumps = true,
            disable = { "vim", "make", "query", "bash", "markdown", "gitcommit" },
            goto_next_start = {
                ["]f"] = "@function.outer",
                ["]C"] = "@call.outer",
                ["]c"] = "@class.outer",
                ["]a"] = "@parameter.inner",
            },
            goto_previous_start = {
                ["[f"] = "@function.outer",
                ["[c"] = "@class.outer",
                ["[C"] = "@call.outer",
                ["[a"] = "@parameter.inner",
            },
        },
    },
})
