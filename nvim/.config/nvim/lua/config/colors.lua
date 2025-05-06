local M = {}

function M.setup()
    -- Lighter indent guide
    vim.api.nvim_set_hl(0, "IblIndent", { fg = "#444444", nocombine = true })

    -- Optional: Current indent scope line
    vim.api.nvim_set_hl(0, "IblScope",     { fg = "#666666", nocombine = true })
    vim.api.nvim_set_hl(0, "LineNr",       { fg = "#c8c093", bold = false }) -- current
    vim.api.nvim_set_hl(0, "LineNrAbove",  { fg = "#667b89", bold = false })
    vim.api.nvim_set_hl(0, "LineNrBelow",  { fg = "#7e7087", bold = false }) --
end

return M
