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

vim.api.nvim_del_user_command("Man") -- remove the built-in one
vim.api.nvim_create_user_command("Man",
    function(opts)
        -- Grab the man output and open it in the current buffer
        local topic = table.concat(opts.fargs, " ")
        local output = vim.fn.systemlist("man " .. topic .. " | col -b")
        vim.cmd("enew")
        vim.api.nvim_buf_set_lines(0, 0, -1, false, output)
        vim.bo.filetype = "man"
        vim.bo.modified = false
    end, {
        nargs = "+",
        complete = "shellcmd",
})

vim.api.nvim_create_user_command("CTest", function()
  local old_makeprg = vim.o.makeprg
  local old_errorformat = vim.o.errorformat

  vim.o.makeprg = "ctest --output-on-failure --test-dir build"
  vim.o.errorformat = table.concat({
    "%f|%l| %m",      -- matches file|line| Failure
    "%f:%l: %m",      -- fallback: file:line: message (e.g. from gtest)
    "%-G%.%#",        -- ignore everything else
  }, ",")

  vim.cmd("make")

  -- Restore previous make settings
  vim.o.makeprg = old_makeprg
  vim.o.errorformat = old_errorformat
end, {})


local find_project_root = require("plenary.path").find_upwards

-- vim.api.nvim_create_user_command("RunTest", function(opts)
--   local target = opts.args
--   if target == "" then
--     vim.notify("❗ Please provide a test target name", vim.log.levels.WARN)
--     return
--   end
--
--   local root = find_project_root("CMakeLists.txt")
--   if not root then
--     vim.notify("❌ Could not find CMake project root", vim.log.levels.ERROR)
--     return
--   end
--
--   -- Use build/ inside project root
--   local build_dir = root .. "/build"
--
--   -- Terminal buffer at bottom
--   local term_buf = vim.api.nvim_create_buf(false, true)
--   vim.cmd("botright 15split")
--   vim.api.nvim_win_set_buf(0, term_buf)
--   vim.bo[term_buf].filetype = "log"
--
--   -- Launch make and the test binary from inside build/
--   vim.fn.termopen({ "sh", "-c", string.format("make %s && ./%s", target, target) }, {
--     cwd = build_dir,
--   })
-- end, {
--   nargs = 1,
--   complete = "file",
-- })
