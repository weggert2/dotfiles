-- Telescope keymaps
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files"        })
vim.keymap.set("n", "<leader>gr", "<cmd>Telescope live_grep<CR>",  { desc = "Grep in files"     })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>",    { desc = "List open buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>",  { desc = "Help tags"         })
vim.keymap.set("n", "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "Fuzzy search in current buffer" })

-- Example: exit terminal mode
vim.keymap.set("t", "<C-q>", [[<C-\><C-n>]], { desc = "Exit terminal mode", noremap = true })

-- Fast access to config files
local config = vim.fn.stdpath("config")
vim.keymap.set("n", "<leader>ei", "<cmd>edit " .. config .. "/init.lua<CR>",                  { desc = "Edit init.lua"         })
vim.keymap.set("n", "<leader>ep", "<cmd>edit " .. config .. "/lua/plugins/init.lua<CR>",      { desc = "Edit plugins/init.lua" })
vim.keymap.set("n", "<leader>ek", "<cmd>edit " .. config .. "/lua/config/keymaps.lua<CR>",    { desc = "Edit keymaps.lua"      })
vim.keymap.set("n", "<leader>et", "<cmd>edit " .. config .. "/lua/config/treesitter.lua<CR>", { desc = "Edit treesitter.lua"   })
vim.keymap.set("n", "<leader>el", "<cmd>edit " .. config .. "/lua/config/lazy.lua<CR>",       { desc = "Edit lazy.lua"         })
vim.keymap.set("n", "<leader>ec", "<cmd>edit " .. config .. "/lua/config/commands.lua<CR>",   { desc = "Edit commands.lua"     })
vim.keymap.set("n", "<leader>ea", "<cmd>edit " .. config .. "/lua/config/autocmds.lua<CR>",   { desc = "Edit autocmds.lua"     })
vim.keymap.set("n", "<leader>er", "<cmd>edit " .. config .. "/lua/config/colors.lua<CR>",     { desc = "Edit colors.lua"       })

-- Paste without yanking. Why does everything yank?
vim.keymap.set("x", "p", '"_dP', { noremap = true, silent = true })

-- Delete without yank (black hole register)
vim.keymap.set("n", "d", '"_d',   { noremap = true })
vim.keymap.set("n", "dd", '"_dd', { noremap = true })
vim.keymap.set("n", "D", '"_D',   { noremap = true })
vim.keymap.set("v", "d", '"_d',   { noremap = true })
vim.keymap.set("v", "D", '"_D',   { noremap = true })

-- Change without yanking
vim.keymap.set("n", "c", '"_c', { noremap = true })
vim.keymap.set("n", "C", '"_C', { noremap = true })
vim.keymap.set("n", "d", '"_d', { noremap = true })
vim.keymap.set("n", "D", '"_D', { noremap = true })
vim.keymap.set("n", "x", '"_x', { noremap = true })
vim.keymap.set("n", "X", '"_X', { noremap = true })
vim.keymap.set("n", "s", '"_s', { noremap = true })
vim.keymap.set("n", "S", '"_S', { noremap = true })

-- Visual mode variants
vim.keymap.set("v", "d", '"_d', { noremap = true })
vim.keymap.set("v", "x", '"_x', { noremap = true })
vim.keymap.set("v", "c", '"_c', { noremap = true })
vim.keymap.set("v", "s", '"_s', { noremap = true })

-- Yank+delete using <leader>
vim.keymap.set("n", "<leader>d", "d",   { noremap = true, desc = "Delete with yank" })
vim.keymap.set("n", "<leader>dd", "dd", { noremap = true, desc = "Delete line with yank" })
vim.keymap.set("n", "<leader>D", "D",   { noremap = true, desc = "Delete to EOL with yank" })
vim.keymap.set("v", "<leader>d", "d",   { noremap = true, desc = "Delete with yank (visual)" })
vim.keymap.set("v", "<leader>D", "D",   { noremap = true, desc = "Delete to EOL with yank (visual)" })

-- git-conflict
vim.keymap.set("n", "<leader>ac", "<cmd>GitConflictChooseOurs<CR>",   { desc = "Accept Current", noremap = true, silent = true })
vim.keymap.set("n", "<leader>ai", "<cmd>GitConflictChooseTheirs<CR>", { desc = "Accept Incoming", noremap = true, silent = true })
vim.keymap.set("n", "<leader>ab", "<cmd>GitConflictChooseBoth<CR>",   { desc = "Accept Both", noremap = true, silent = true })
vim.keymap.set("n", "<leader>aq", "<cmd>GitConflictListQf<CR>",       { desc = "List Conflicts (Quickfix)", noremap = true, silent = true })

-- Paste below/above the current line
vim.keymap.set("n", "<leader>p", function() vim.cmd("put")  end, { desc = "Paste below line" })
vim.keymap.set("n", "<leader>P", function() vim.cmd("put!") end, { desc = "Paste above line" })

-- Normal mode: move current line up/down without reindenting
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })

-- Visual mode: move selection and *do not* reindent
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv", { desc = "Move selection down", silent = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv", { desc = "Move selection up", silent = true })

-- Page up/down with ctrl+j/k (and center)
vim.keymap.set("n", "<C-j>", "<C-d>zz", { desc = "Scroll down + center", noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "<C-u>zz", { desc = "Scroll up + center", noremap = true, silent = true })

local copilot_enabled = true
vim.keymap.set("n", "<leader>ct", function()
    copilot_enabled = not copilot_enabled
    if copilot_enabled then
        vim.cmd("Copilot enable")
        print("Copilot enabled")
    else
        vim.cmd("Copilot disable")
        print("Copilot disabled")
    end
end, { noremap = true, silent = true, desc = "Toggle Copilot" })

-- Quickfix
vim.keymap.set("n", "<leader>co", function()
    local qf_list = vim.fn.getqflist()
    if vim.tbl_isempty(qf_list) then
        vim.notify("Quickfix list is empty", vim.log.levels.WARN)
        return
    end

    vim.cmd("botright vertical copen")

    -- Resize to half the screen width
    local half_width = math.floor(vim.o.columns / 2)
    vim.cmd("vertical resize " .. half_width)
    vim.cmd("cfirst")
    -- if #qf_list > 1 then
    --     pcall(vim.cmd, "cnext")
    -- end
end, { desc = "Open quickfix list in right split, resized to 50%, and jump to first error" })

vim.keymap.set("n", "<leader>cc", function()
    for _, win in ipairs(vim.fn.getwininfo()) do
        if win.quickfix == 1 then
            vim.cmd("cclose")
            return
        end
    end
    vim.notify("Quickfix window is not open", vim.log.levels.INFO)
end, { desc = "Close quickfix window if open" })

vim.keymap.set("n", "<leader>cn", function()
    local ok, err = pcall(vim.cmd, "cnext")
    if not ok then
        vim.notify("No more (next) errors", vim.log.levels.INFO)
    end
end, { desc = "Next quickfix item" })

vim.keymap.set("n", "<leader>cp", function()
    local ok, err = pcall(vim.cmd, "cprev")
    if not ok then
        vim.notify("No more (prev) errors", vim.log.levels.INFO)
    end
end, { desc = "Prev quickfix item" })

-- Treesitter keymaps
vim.api.nvim_create_user_command("TSKeymaps", function()
  vim.print(require("nvim-treesitter.configs").get_module("textobjects.select").keymaps)
end, {})

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition", noremap = true, silent = true })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration", noremap = true, silent = true })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation", noremap = true, silent = true })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go to references", noremap = true, silent = true })

vim.keymap.set("n", "<leader>Gd", "<cmd>Glance definitions<CR>", { desc = "Glance Definitions", noremap = true, silent = true })
vim.keymap.set("n", "<leader>Gr", "<cmd>Glance references<CR>", { desc = "Glance References", noremap = true, silent = true })
vim.keymap.set("n", "<leader>Gi", "<cmd>Glance implementations<CR>", { desc = "Glance Implementations", noremap = true, silent = true })
vim.keymap.set("n", "<leader>Gt", "<cmd>Glance type_definitions<CR>", { desc = "Glance Type Definitions", noremap = true, silent = true })
vim.keymap.set("n", "gm", "50%zz", { desc = "Jump to middle of file"})

-- Jump to the source
vim.keymap.set("n", "gs", function()
    local params = { uri = vim.uri_from_bufnr(0) }

    for _, client in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
        if client.name == "clangd" and client:supports_method("textDocument/switchSourceHeader") then
            client:request("textDocument/switchSourceHeader", params, function(err, result)
                if result then
                    vim.cmd("edit " .. vim.uri_to_fname(result))
                else
                    vim.notify("No corresponding source/header file found", vim.log.levels.WARN)
                end
            end, 0)
            return
        end
    end

    vim.notify("Clangd is not active or doesn't support header/source switching", vim.log.levels.WARN)
end, { desc = "Switch between header/source" })

-- Jump to the definition in a split
vim.keymap.set("n", "<leader>gd", function()
    local params = vim.lsp.util.make_position_params()

    local function open_location(result)
        if not result or vim.tbl_isempty(result) then
            vim.notify("No definition found", vim.log.levels.WARN)
            return
        end

        local location = result[1] or result
        local uri = location.uri or location.targetUri
        local filename = vim.uri_to_fname(uri)
        local bufnr = vim.fn.bufnr(filename)

        -- Check if buffer is already visible in a window
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == bufnr then
                vim.api.nvim_set_current_win(win)
                vim.lsp.util.jump_to_location(location, "utf-8")
                return
            end
        end

        -- Not visible → open in split
        vim.cmd("vsplit " .. filename)
        vim.lsp.util.jump_to_location(location, "utf-8")
    end

    -- Request definition and apply logic
    for _, client in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
        if client:supports_method("textDocument/definition") then
            client:request("textDocument/definition", params, function(err, result)
                if err then
                    vim.notify("LSP error: " .. err.message, vim.log.levels.ERROR)
                    return
                end
                open_location(result)
            end, 0)
            return
        end
    end

    vim.notify("LSP client does not support textDocument/definition", vim.log.levels.WARN)
end, { desc = "Go to definition (smart split)" })

-- Go to test file
vim.keymap.set("n", "gt", function()
    local current = vim.api.nvim_buf_get_name(0)
    local dir = vim.fn.fnamemodify(current, ":h")
    local file = vim.fn.fnamemodify(current, ":t")
    local is_test = dir:match("/test$")

    -- Strip common C/C++ extensions
    local function strip_extension(fname)
        return fname
            :gsub("%.cpp$", "")
            :gsub("%.cxx$", "")
            :gsub("%.cc$", "")
            :gsub("%.c$", "")
            :gsub("%.hpp$", "")
            :gsub("%.hxx$", "")
            :gsub("%.hh$", "")
            :gsub("%.h$", "")
    end

    local function jump_to(candidates)
        for _, path in ipairs(candidates) do
            if vim.fn.filereadable(path) == 1 then
                vim.cmd("edit " .. path)
                return
            end
        end

        vim.notify("File not found: " .. file, vim.log.levels.WARN)
    end

    -- Jump from test → source
    if is_test and file:match("^Test") then
        local base = file:match("^Test(.+)$")
        base = strip_extension(base or "")
        local parent_dir = vim.fn.fnamemodify(dir, ":h")

        local candidates = {
            parent_dir .. "/" .. base .. ".cpp",
            parent_dir .. "/" .. base .. ".cxx",
            parent_dir .. "/" .. base .. ".cc",
            parent_dir .. "/" .. base .. ".c",
            parent_dir .. "/" .. base .. ".hpp",
            parent_dir .. "/" .. base .. ".hxx",
            parent_dir .. "/" .. base .. ".hh",
            parent_dir .. "/" .. base .. ".h",
        }

        jump_to(candidates)
        return
    end

    -- Jump from source → test
    local basename = strip_extension(file)
    local test_dir = dir .. "/test"

    local candidates = {
        test_dir .. "/Test" .. basename .. ".cpp",
        test_dir .. "/Test" .. basename .. ".cxx",
        test_dir .. "/Test" .. basename .. ".cc",
        test_dir .. "/Test" .. basename .. ".c",
    }

    jump_to(candidates)
end, { desc = "Toggle between source and test file" })

