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

local cpp_errorformat = table.concat({
    "%f:%l:%c: %t%*[^:]: %m",
    "%f:%l: %m",
}, ",")

local function parse_gtest_output(filepath)
    local f = io.open(filepath, "r")
    if not f then return nil, "Could not open " .. filepath end

    local lines = {}
    for line in f:lines() do
        table.insert(lines, line)
    end
    f:close()

    local qf = {}
    local i = 1
    while i <= #lines do
        local line = lines[i]
        if line:match("^%[ RUN      %]") then
            local filename, linenum, msglines = nil, nil, {}

            for j = i + 1, math.min(i + 10, #lines) do
                local f, l = lines[j]:match("^(.-):(%d+): Failure")
                if f and l then
                    filename = f
                    linenum = tonumber(l)
                    i = j + 1
                    while i <= #lines and not lines[i]:match("^%[  FAILED  %]") do
                        table.insert(msglines, lines[i])
                        i = i + 1
                    end
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

    return qf
end

local function set_quickfix_and_notify(qf, title, label)
    vim.fn.setqflist(qf, "r")
    if #qf == 0 then
        vim.notify("✅ " .. label .. " passed", vim.log.levels.INFO, { title = title })
        -- No errors, close the quickfix window if it's open
        for _, win in ipairs(vim.fn.getwininfo()) do
            if win.quickfix == 1 then
                vim.cmd("cclose")
                break
            end
        end
    else
        vim.notify("❌ " .. label .. " failed with " .. #qf .. " issue(s)", vim.log.levels.ERROR, { title = title })
    end
    os.remove("testresults.txt")
end

vim.api.nvim_create_user_command("Test", function()
    local old_makeprg = vim.o.makeprg
    local old_errorformat = vim.o.errorformat

    vim.o.makeprg = "ctest-capture-output"
    vim.o.errorformat = cpp_errorformat

    vim.cmd("make")

    local qf, err = parse_gtest_output("testresults.txt")
    if not qf then
        vim.notify(err, vim.log.levels.ERROR)
        return
    end

    set_quickfix_and_notify(qf, "Test", "All tests")

    vim.o.makeprg = old_makeprg
    vim.o.errorformat = old_errorformat
end, {})

vim.api.nvim_create_user_command("RunTest", function(opts)
    local testname = opts.args
    if testname == "" then
        vim.notify("RunTest requires a test name", vim.log.levels.ERROR)
        return
    end

    local old_makeprg = vim.o.makeprg
    local old_errorformat = vim.o.errorformat

    vim.o.makeprg = "ctest-run-one " .. vim.fn.shellescape(testname)
    vim.o.errorformat = cpp_errorformat

    vim.cmd("make")

    local qf, err = parse_gtest_output("testresults.txt")
    if not qf then
        vim.notify(err, vim.log.levels.ERROR)
        return
    end

    set_quickfix_and_notify(qf, "RunTest", testname)

    vim.o.makeprg = old_makeprg
    vim.o.errorformat = old_errorformat
end, {
    nargs = 1,
})

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

