-- Custom :Build command with optional flags
vim.api.nvim_create_user_command("Build", function(opts)
  -- Parse and sanitize args
  local args = opts.args ~= "" and vim.split(opts.args, " ", { trimempty = true }) or {}

  -- Start with base build command
  local cmd_parts = {
    "cmake", "-S", ".", "-B", "build", "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
  }

  -- Append sanitized user args
  for _, arg in ipairs(args) do
    if arg ~= nil then
      table.insert(cmd_parts, tostring(arg))
    end
  end

  -- Add the build step
  vim.list_extend(cmd_parts, {
    "&&",
    "cmake", "--build", "build", "-j12"
  })

  -- Safely concat
  local build_cmd = table.concat(cmd_parts, " ")

  -- Launch in terminal split
  vim.cmd("rightbelow vsplit")
  vim.cmd("terminal sh -c " .. vim.fn.shellescape(build_cmd .. "; exec zsh"))
  vim.cmd("startinsert")
end, {
  nargs = "*",
  complete = "shellcmd",
  desc = "Build the project with optional CMake args",
})

-- :Test command for running tests
vim.api.nvim_create_user_command("Test", function()
    vim.fn.jobstart({ "ctest", "--test-dir", "build", "--stop-on-failure" }, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
            if data then vim.fn.setqflist({}, ' ', { title = "Test Output", lines = data }) end
        end,
        on_exit = function(_, code)
            if code == 0 then
                vim.notify("✅ Tests passed", vim.log.levels.INFO)
            else
                vim.cmd("copen")
                vim.notify("❌ Some tests failed", vim.log.levels.WARN)
            end
        end,
    })
end, { desc = "Run tests with CTest" })

