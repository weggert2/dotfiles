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
    -- {
    --     "hrsh7th/nvim-cmp",            -- Main completion engine
    --     dependencies = {
    --         "hrsh7th/cmp-nvim-lsp",      -- LSP completions
    --         "hrsh7th/cmp-buffer",        -- Buffer words
    --         "hrsh7th/cmp-path",          -- Filesystem paths
    --         "hrsh7th/cmp-cmdline",       -- Command-line completions
    --         "L3MON4D3/LuaSnip",          -- Snippet engine
    --         "saadparwaiz1/cmp_luasnip",  -- Snippet completions
    --     },
    --     config = function()
    --         local cmp = require("cmp")
    --         local luasnip = require("luasnip")
    --
    --         cmp.setup({
    --             completion = {
    --                 autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged },
    --                 keyword_length = 4, -- don't trigger until 4 characters typed
    --             },
    --             snippet = {
    --                 expand = function(args)
    --                     luasnip.lsp_expand(args.body)
    --                 end,
    --             },
    --             mapping = cmp.mapping.preset.insert({
    --                 ["<C-Space>"] = cmp.mapping.complete(),
    --                 ["<CR>"] = cmp.mapping.confirm({ select = true }),
    --                 ["<Tab>"] = cmp.mapping(function(fallback)
    --                     if cmp.visible() then
    --                         cmp.select_next_item()
    --                     elseif luasnip.expand_or_jumpable() then
    --                         luasnip.expand_or_jump()
    --                     else
    --                         fallback()
    --                     end
    --                 end, { "i", "s" }),
    --                 ["<S-Tab>"] = cmp.mapping(function(fallback)
    --                     if cmp.visible() then
    --                         cmp.select_prev_item()
    --                     elseif luasnip.jumpable(-1) then
    --                         luasnip.jump(-1)
    --                     else
    --                         fallback()
    --                     end
    --                 end, { "i", "s" }),
    --             }),
    --             cmp.setup.filetype("cmake", {
    --                 completion = {
    --                     keyword_length = 2,
    --                 },
    --             }),
    --             sources = cmp.config.sources({
    --                 { name = "nvim_lsp", priority = 5 },
    --                 { name = "luasnip",  priority = 3 },
    --                 { name = "buffer",   priority = 7 },
    --                 { name = "path",     priority = 4 },
    --             }),
    --             sorting = {
    --                 priority_weight = 2,
    --                 comparators = {
    --                     cmp.config.compare.offset,
    --                     cmp.config.compare.exact,
    --                     cmp.config.compare.score,
    --                     cmp.config.compare.kind,
    --                     cmp.config.compare.sort_text,
    --                     cmp.config.compare.length,
    --                     cmp.config.compare.order,
    --                 },
    --             },
    --         })
    --     end,
    -- },
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
        "mfussenegger/nvim-dap",
        config = function()
            local dap = require("dap")

            dap.adapters.codelldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
                    args = { "--port", "${port}" },
                },
            }

            dap.configurations.cpp = {
                {
                    name = "Launch file",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = true,
                },
            }

            dap.configurations.c = dap.configurations.cpp
            dap.configurations.rust = dap.configurations.cpp
        end
    },
    {
        "nvim-neotest/nvim-nio",
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
        config = function()
            require("dapui").setup()
        end,
    },
    {
        "mfussenegger/nvim-dap-python",
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            require("dap-python").setup("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")
        end,
        ft = { "python" },
    },
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "mfussenegger/nvim-dap", "williamboman/mason.nvim" },
        config = function()
            require("mason-nvim-dap").setup({
                ensure_installed = { "codelldb" },
                automatic_installation = true,
            })
        end,
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
            { "<leader>s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
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
                    ignore = false,
                },
                renderer = {
                    highlight_git = true,
                    icons = {
                        git_placement = "before", -- "before" puts icon before the filename
                        glyphs = {
                            git = {
                                unstaged = "~",   -- ← changed (was "✗")
                                staged = "+",     -- added to index
                                unmerged = "",   -- merge conflict
                                renamed = "➜",    -- renamed
                                untracked = "?",  -- untracked
                                deleted = "✘",    -- deleted
                                ignored = "◌",    -- ignored
                            },
                        },
                    },
                },
                view = {
                    width = 30,
                    side = "left",
                },
            })

            -- Toggle with <leader>nt
            vim.keymap.set("n", "<leader>nt", ":NvimTreeToggle<CR>", { desc = "Toggle nvim-tree" })

            -- Disable color for other Git statuses
            -- vim.api.nvim_set_hl(0, "NvimTreeGitDirty", {})
            -- vim.api.nvim_set_hl(0, "NvimTreeGitStaged", {})
            -- vim.api.nvim_set_hl(0, "NvimTreeGitNew", {})
            -- vim.api.nvim_set_hl(0, "NvimTreeGitDeleted", {})
            -- vim.api.nvim_set_hl(0, "NvimTreeGitRenamed", {})
        end,
    },
    {
        "mg979/vim-visual-multi",
        branch = "master",
        init = function()
            vim.g.VM_default_mappings = true
            vim.g.VM_maps = {
                ["Find Under"] = "<C-n>",
                ["Find Subword Under"] = "<C-n>",
                ["Remove Region"] = "<C-u>",
                ["Skip Region"] = "<C-j>", -- skip current and move to next
                ["Align"] = "<M-a>",
            }
        end,
        config = function()
            local red = "#ff5555"
            local white = "#ffffff"
            local bold = true

            local groups = {
                "VM_Extend",
                "VM_Cursor",
                "VM_Insert",
                "VM_Mono",
                "VM_Selection",
            }

            for _, group in ipairs(groups) do
                vim.api.nvim_set_hl(0, group, {
                    ctermbg = 203,
                    ctermfg = 15,
                    bg = red,
                    fg = white,
                    bold = bold,
                })
            end
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
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('lualine').setup({
                options = {
                    theme = 'auto',
                    icons_enabled = false,
                    section_separators = '',
                    component_separators = '',
                    globalstatus = true,
                },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = {},
                    lualine_c = {{'filename', path = 1 }},
                    lualine_x = { 'filetype' },
                    lualine_y = {
                        function()
                            return os.date("%H:%M %Z | %d-%b-%y")
                        end,
                    },
                    lualine_z = { 'location' },
                },
            })
        end,
    },
}
