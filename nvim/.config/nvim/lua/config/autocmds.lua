-- Trim trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

-- Open nvim-tree when entering a directory
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
            vim.cmd("NvimTreeToggle")
        end
    end,
})


vim.api.nvim_create_autocmd("QuickFixCmdPre", {
    pattern = "make",
    callback = function()
        vim.cmd("write")
    end,
})

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    pattern = "make",
    callback = function()
        if vim.tbl_isempty(vim.fn.getqflist()) then
            -- No errors, close the quickfix window if it's open
            for _, win in ipairs(vim.fn.getwininfo()) do
                if win.quickfix == 1 then
                    vim.cmd("cclose")
                    break
                end
            end
        end
    end,
})
