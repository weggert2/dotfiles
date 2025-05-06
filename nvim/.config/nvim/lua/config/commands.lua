vim.api.nvim_create_user_command("LazyKeys", function()
    -- Clear all user-defined keymaps in normal mode (and others if needed)
    for _, mode in ipairs({ "n", "v", "x", "o", "i", "t" }) do
        for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
            if map.desc or (map.lhs and map.lhs:match("^<leader>")) then
                pcall(vim.keymap.del, mode, map.lhs)
            end
        end
    end

    -- Reload your keymaps module
    package.loaded["config.keymaps"] = nil
    require("config.keymaps")

    vim.notify("Keymaps reloaded!", vim.log.levels.INFO)
end, { desc = "Reload custom keymaps" })


-- Utility: Find open terminal buffer by name
local function find_terminal_buf()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local name = vim.api.nvim_buf_get_name(buf)
        if name:find("term://") then
            return buf
        end
    end
    return nil
end

-- Define :Term command
vim.api.nvim_create_user_command("Term", function(opts)
    local cmd = opts.args
    local term_buf = find_terminal_buf()

    if term_buf == nil then
        -- No terminal open: open vertical split, start terminal, run command
        vim.cmd("vsplit")
        vim.cmd("terminal")
        vim.cmd("startinsert")

        -- Defer sending the command until terminal is ready
        vim.defer_fn(function()
            if cmd ~= "" then
                vim.api.nvim_chan_send(vim.b.terminal_job_id, cmd .. "\n")
            end
        end, 100)
    else
        -- Terminal already exists — send command
        vim.api.nvim_set_current_buf(term_buf)
        vim.cmd("startinsert")
        vim.api.nvim_chan_send(vim.b.terminal_job_id, cmd .. "\n")
    end
end, {
    nargs = "*",
    complete = "shellcmd",
    desc = "Smart terminal runner with reuse",
})
