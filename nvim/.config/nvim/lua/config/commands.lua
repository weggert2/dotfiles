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

vim.api.nvim_create_user_command("Test", function()
    local old_makeprg = vim.o.makeprg
    local old_errorformat = vim.o.errorformat

    -- Set makeprg to a script in ~/.local/bin that builds and captures tests
    -- output. This is because I couldn't figure out how to pipe to an output
    -- file usig vim lua
    vim.o.makeprg = "ctest-capture-output"
    vim.o.errorformat = table.concat({
        "%f:%l:%c: %t%*[^:]: %m", -- filename:line:col: [type] message
        "%f:%l: %m",              -- filename:line: message (fallback)
    }, ",")

    -- Run :make which uses makeprg to do the testing
    vim.cmd("make")

    local filepath = "testresults.txt"
    local f = io.open(filepath, "r")
    if not f then
        vim.notify("No testresults.txt found", vim.log.levels.ERROR)
        vim.o.makeprg = old_makeprg
        vim.o.errorformat = old_errorformat
        return
    end

    local qf = {}
    local lines = {}
    for line in f:lines() do
        table.insert(lines, line)
    end
    f:close()

    local i = 1
    while i <= #lines do
        local line = lines[i]

        -- Look for a line called "RUN". All tests hae this, including
        -- failed tests
        if line:match("^%[ RUN      %]") then
            local filename, linenum, msglines = nil, nil, {}

            -- If the next line contains "Failure", then the test failed.
            for j = i + 1, math.min(i + 10, #lines) do
                -- Parse into a format quickfix can understand
                local f, l = lines[j]:match("^(.-):(%d+): Failure")
                if f and l then
                    filename = f
                    linenum = tonumber(l)
                    i = j + 1

                    -- Capture output until the FAILED, which will get the whole
                    -- error message
                    while i <= #lines and not lines[i]:match("^%[  FAILED  %]") do
                        table.insert(msglines, lines[i])
                        i = i + 1
                    end

                    -- Put what we just captured into the quickfix list
                    if filename and linenum and #msglines > 0 then
                        table.insert(qf, {
                            filename = filename,
                            lnum = linenum,
                            col = 1,
                            text = table.concat(msglines, "\n"),
                            type = "E",
                        })
                    end
                    break
                end
            end
        else
            i = i + 1
        end
    end

    -- Set the whole quickfix list with our local qf, report result
    vim.fn.setqflist(qf, "r")

    if #qf == 0 then
        vim.notify("✅ All tests passed!", vim.log.levels.INFO, { title = "Test" })
    else
        vim.notify("❌ Test suite failed with " .. #qf .. " issue(s)", vim.log.levels.ERROR, { title = "Test" })
    end

    -- Clean up
    os.remove("testresults.txt")

    -- Restore settings
    vim.o.makeprg = old_makeprg
    vim.o.errorformat = old_errorformat
end, {})



vim.api.nvim_create_user_command("Check", function()
    local old_makeprg = vim.o.makeprg
    vim.o.makeprg = "./scripts/run_cppcheck.sh"

    vim.cmd("make")
    local exit_code = vim.v.shell_error

    if exit_code == 0 then
        -- No issues found.
        vim.o.makeprg = old_makeprg
        return
    end

    local filepath = "allcppchecks.txt"
    local f = io.open(filepath, "r")
    if not f then
        vim.notify("Cppcheck output file not found", vim.log.levels.ERROR)
        vim.o.makeprg = old_makeprg
        return
    end

    local qf = {}
    for line in f:lines() do
        local file, lnum, col, msg = line:match("^(.-):(%d+):(%d+):%s*[^:]+:%s*(.+)%s+%[.-%]$")
        if file and lnum and col and msg then
            table.insert(qf, {
                filename = file,
                lnum = tonumber(lnum),
                col = tonumber(col),
                text = msg,
                type = "W",
            })
        end
    end
    f:close()
    vim.fn.setqflist(qf, "r")

    vim.o.makeprg = old_makeprg
end, {})

