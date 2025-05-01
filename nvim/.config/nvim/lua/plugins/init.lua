return {
    {
        "rebelot/kanagawa.nvim",
        priority = 1000,
        config = function()
            vim.cmd("colorscheme kanagawa")
        end,
    },
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.3",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup()
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("config.treesitter")
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = "nvim-treesitter/nvim-treesitter",
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({
                check_ts = true,  -- Enable Treesitter-aware pairing
                map_cr = true,    -- Enable <CR> to auto-wrap braces
            })
        end,
    },
    {
        "hrsh7th/nvim-cmp",            -- Main completion engine
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",      -- LSP completions
            "hrsh7th/cmp-buffer",        -- Buffer words
            "hrsh7th/cmp-path",          -- Filesystem paths
            "hrsh7th/cmp-cmdline",       -- Command-line completions
            "L3MON4D3/LuaSnip",          -- Snippet engine
            "saadparwaiz1/cmp_luasnip",  -- Snippet completions
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                completion = {
                    autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged },
                    keyword_length = 4, -- don't trigger until 2 characters typed
                },
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                cmp.setup.filetype("cmake", {
                    completion = {
                        keyword_length = 2,
                    },
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp", priority = 5 },
                    { name = "luasnip",  priority = 3 },
                    { name = "buffer",   priority = 7 },
                    { name = "path",     priority = 4 },
                }),
                sorting = {
                    priority_weight = 2,
                    comparators = {
                        cmp.config.compare.offset,
                        cmp.config.compare.exact,
                        cmp.config.compare.score,
                        cmp.config.compare.kind,
                        cmp.config.compare.sort_text,
                        cmp.config.compare.length,
                        cmp.config.compare.order,
                    },
                },
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            require("lspconfig").clangd.setup({
                cmd = { "clangd", "--background-index", "--all-scopes-completion" },
                root_dir = require("lspconfig.util").root_pattern(
                    "compile_commands.json",
                    "compile_flags.txt",
                    ".git"
                ),
            })
            require("lspconfig").rust_analyzer.setup({})
            require("lspconfig").cmake.setup({})
            require("lspconfig").pylsp.setup({})
            -- Add more LSPs here as needed
        end,
    },

    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {
            indent = { char = "│" }, -- or "▏", "┆", "⎸", "¦"
            scope = { enabled = true },
        },
        event = "BufReadPre",
    },
    {
        "numToStr/Comment.nvim",
        opts = {},  -- works out of the box
        lazy = false,
    },
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        ---@type Flash.Config
        opts = {},
        -- stylua: ignore
        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
            { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
            { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
            { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
        },
    },
    {
        "dnlhc/glance.nvim",
        config = function()
            require("glance").setup({})
        end,
    },
    {
        "stevearc/oil.nvim",
        opts = {},
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("oil").setup()
        end
    }
}

