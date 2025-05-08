-- Trim trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = {
        "c", "cpp", "cc", "cxx",
        "h", "hh", "hpp", "hxx",
        "objc", "objcpp", "cuda",
        "tpp", "icc", "inl", "ixx",
    },
    callback = function()
        vim.keymap.set("x", "=", ":'<,'>!clang-format<CR>gv", { buffer = true })
    end,
})

-- Project detection + nvim-tree auto-open
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        local argv = vim.fn.argv()
        local uv = vim.loop

        -- 1. Auto-open nvim-tree when opening a folder
        if vim.fn.argc() == 1 and vim.fn.isdirectory(argv[0]) == 1 then
            vim.cmd("NvimTreeToggle")
        end

        -- 2. Detect what type of project we're in (CMake = C, cargo = Rust, etc)
        local function exists(path)
            local stat = uv.fs_stat(path)
            return stat and stat.type == "file"
        end

        local function find_project_root(markers)
            local cwd = vim.fn.getcwd()
            while cwd do
                for _, marker in ipairs(markers) do
                    if exists(cwd .. "/" .. marker) then
                        return cwd
                    end
                end
                local parent = vim.fn.fnamemodify(cwd, ":h")
                if parent == cwd then break end
                cwd = parent
            end
        end

        local root = find_project_root({ "CMakeLists.txt" })
        if root then
            vim.opt.makeprg = table.concat({
                "cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTS=ON -DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
                "cmake --build build --parallel 12",
            }, " && ")

            vim.opt.errorformat = table.concat({
                "%f:%l:%c: %t%*[^:]: %m",
                "%f:%l: %t%*[^:]: %m",
                "%-G%.%#",
            }, ",")

            vim.notify("🛠️ CMake project detected — :make is ready", vim.log.levels.INFO)
        end
    end,
})

local build_start_time = nil

vim.api.nvim_create_autocmd("QuickFixCmdPre", {
    pattern = "make",
    callback = function()
        local bt = vim.bo.buftype
        if bt == "" and not vim.bo.readonly and vim.bo.modifiable then
            vim.cmd("write")
        end
        build_start_time = vim.loop.hrtime()
    end,
})


vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    pattern = "make",
    callback = function()
        if vim.o.makeprg == "ctest-capture-output" or
           vim.o.makeprg:find("ctest-run-one", 1, true) then
            -- Don't show notifications for ctest
            return
        end

        local qf_size = vim.fn.getqflist({ size = 0 }).size
        local elapsed_s = ""
        if build_start_time then
            local elapsed_ns = vim.loop.hrtime() - build_start_time
            elapsed_s = string.format(" in %.2fs", elapsed_ns * 1e-9)
        end
        if (qf_size == 0 and vim.v.shell_error == 0) then
            vim.notify(
                "✅ Task succeeded!" .. elapsed_s, vim.log.levels.INFO, {
                    title = "Make"
            })
            -- No errors, close the quickfix window if it's open
            for _, win in ipairs(vim.fn.getwininfo()) do
                if win.quickfix == 1 then
                    vim.cmd("cclose")
                    break
                end
            end
        elseif qf_size > 0 then
            -- Notify errors.
            vim.notify(
                "❌ Task failed with " .. qf_size .. " issues" ..
                elapsed_s, vim.log.levels.INFO, {
                    title = "Make"
            })
        elseif vim.v.shell_error ~= 0 then
            -- Nofity errors without count (maybe linker errors)
            vim.notify(
                "❌ Task failed" ..
                elapsed_s, vim.log.levels.INFO, {
                    title = "Make"
            })
        end
    end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "man",
  callback = function()
    -- Pressing <CR> on something like accept(2) jumps to that man page
    vim.keymap.set("n", "<CR>", "<C-]>", { buffer = true, silent = true })
  end,
})

-- Auto save on focus lost or buffer leave
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
    callback = function()
        if vim.bo.modified and vim.bo.buftype == "" then
            vim.cmd("silent! write")
        end
    end,
})
