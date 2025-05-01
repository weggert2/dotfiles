local lspconfig = require("lspconfig")

-- C++
lspconfig.clangd.setup({})

-- Rust (will use rust-tools if installed)
local ok, rust_tools = pcall(require, "rust-tools")
if ok then
    rust_tools.setup({
        server = {
            on_attach = function(_, bufnr)
                vim.keymap.set("n", "<leader>rr", "<cmd>RustRunnables<CR>", { buffer = bufnr, desc = "Rust runnables" })
            end,
        },
    })
else
    lspconfig.rust_analyzer.setup({})
end

-- Python (using pylsp from pipx or virtualenv)
lspconfig.pylsp.setup({})
