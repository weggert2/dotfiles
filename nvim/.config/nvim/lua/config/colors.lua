local M = {}

function M.setup()
    -- Lighter indent guide
    vim.api.nvim_set_hl(0, "IblIndent", { fg = "#444444", nocombine = true })

    -- Optional: Current indent scope line
    vim.api.nvim_set_hl(0, "IblScope", { fg = "#666666", nocombine = true })

    -- Optional: Customize comments or line numbers
    -- vim.api.nvim_set_hl(0, "Comment", { fg = "#888888", italic = true })
    -- vim.api.nvim_set_hl(0, "LineNr", { fg = "#555555" })
end

return M
