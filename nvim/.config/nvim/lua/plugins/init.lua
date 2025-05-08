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
            require("telescope").setup({
                defaults = {
                    file_ignore_patterns = {
                        "build/",
                        "lcov%-report/",
                    },
                },
            })
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
                    keyword_length = 4, -- don't trigger until 4 characters typed
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
        "williamboman/mason.nvim",
        config = true,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
        config = function()
            ---@diagnostic disable-next-line
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",
                    "clangd",
                    "rust_analyzer",
                    "pylsp",
                    "cmake",
                },
                automatic_installation = true,
            })
        end,
    },
    {
        "folke/neodev.nvim",
        opts = {}, -- use defaults
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            { "folke/neodev.nvim", config = true },
        },
        config = function()
            local lspconfig = require("lspconfig")
            local util = require("lspconfig.util")

            -- Load Neodev first to enhance lua_ls
            require("neodev").setup({})

            -- C/C++ (Clangd)
            lspconfig.clangd.setup({
                cmd = {
                    "clangd",
                    "--compile-commands-dir=build",
                    "--background-index",
                    "--all-scopes-completion",
                },
                root_dir = util.root_pattern(".git"),
            })

            -- Rust
            lspconfig.rust_analyzer.setup({
                root_dir = util.root_pattern("Cargo.toml", ".git"),
            })

            -- Python
            lspconfig.pylsp.setup({
                root_dir = util.root_pattern("pyproject.toml", "setup.py", ".git"),
            })

            -- CMake
            lspconfig.cmake.setup({
                root_dir = util.root_pattern("CMakeLists.txt", ".git"),
            })

            -- Lua (Neovim config + general Lua)
            lspconfig.lua_ls.setup({
                settings = {
                    Lua = {
                        runtime = {
                            version = "LuaJIT",
                        },
                        telemetry = {
                            enable = false,
                        },
                    },
                },
            })
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
        "lukas-reineke/virt-column.nvim",
        opts = {
            virtcolumn = "80, 100",
            char = "▏",
            highlight = "IblIndent",
        },
    },
    {
        "numToStr/Comment.nvim",
        opts = {},  -- works out of the box
        lazy = false,
    },
    {
        "folke/flash.nvim",
        lazy = false,
        opts = {},
        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump({jump = {pos = "range"}}) end, desc = "Flash" },
            { "fS", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
            { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
            { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
        },
    },
    {
        'dnlhc/glance.nvim',
        cmd = 'Glance'
    },
    {
        "stevearc/oil.nvim",
        opts = {},
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("oil").setup({
                default_file_explorer = false,
            })
        end
    },
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({
                filters = {
                    dotfiles = false,
                    custom = { "^.git$", "node_modules" },
                },
                git = {
                    enable = true,
                },
                view = {
                    width = 30,
                    side = "left",
                },
            })

            -- Toggle with <leader>e
            vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle nvim-tree" })
        end,
    },
    -- {
    --     "rcarriga/nvim-notify",
    --     lazy = false, -- load immediately so vim.notify is overridden early
    --     config = function()
    --         require("notify").setup({
    --             stages = "fade_in_slide_out",
    --             timeout = 3000,
    --             background_colour = "#000000",
    --         })
    --
    --         -- Override default vim.notify
    --         vim.notify = require("notify")
    --     end,
    -- }
    {
        "mg979/vim-visual-multi",
        branch = "master",
        init = function()
            vim.g.VM_default_mappings = true
            vim.g.VM_maps = {
                ["Find Under"] = "<C-d>",
                ["Find Subword Under"] = "<C-d>",
                ["Remove Region"] = "<C-u>",
                ["Skip Region"] = "<C-j>", -- skip current and move to next
                ["Align"] = "<M-a>",
            }
        end,
    },
    {
        "kylechui/nvim-surround",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup()
        end
    },
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({
                suggestion = {
                    enabled = true,
                    auto_trigger = true,
                    keymap = {
                        accept = "<Tab>",
                        accept_word = "<M-f>",
                        accept_line = "<M-e>",
                        next = "<M-]>",
                        prev = "<M-[>",
                        dismiss = "<C-]>",
                    },
                },
                panel = { enabled = false },
                filetypes = {
                    ["*"] = true,
                },
            })
        end,
    },
    {
        "j-hui/fidget.nvim",
        opts = {},
    },
    {
        "akinsho/git-conflict.nvim",
        version = "*",

        ---@diagnostic disable-next-line
        config = function()
            require("git-conflict").setup({
                default_mappings = false,
                highlights = {
                    incoming = "DiffAdd",
                    current = "DiffText",
                },
            })
        end,
    },
}
