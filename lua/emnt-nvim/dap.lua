local dap = require("dap")
local dapui = require("dapui")
local hydra = require("hydra")

local utils = require("emnt-nvim.utils")

local extensions_path = utils.vscode_extensions_path()

-- Use default config for now
dapui.setup()

vim.api.nvim_set_hl(0, 'DapBreakpoint', { link = 'WarningMsg', default = true })
vim.api.nvim_set_hl(0, 'DapBreakpointRejected', { link = 'ErrorMsg', default = true })
vim.api.nvim_set_hl(0, 'DapStopped', { link = 'Insert', default = true })

vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DapBreakpoint' })
vim.fn.sign_define('DapBreakpointCondition', { text = 'ﳁ', texthl = 'DapBreakpoint' })
vim.fn.sign_define('DapLogPoint', { text = '', texthl = 'DapBreakpoint' })
vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DapBreakpointRejected' })
vim.fn.sign_define('DapStopped', { text = '', texthl = 'DapStopped' })

if extensions_path ~= nil then
    local codelldb_path = extensions_path .. "/vadimcn.vscode-lldb/adapter/codelldb"
    if vim.fn.filereadable(codelldb_path) then
        dap.adapters.codelldb = {
            type = "server",
            port = "${port}",
            executable = {
                command = codelldb_path,
                args = { "--port", "${port}" },
            }
        }
    end
end
if vim.fn.executable("dlv") == 1 then
    dap.adapters.go = {
        type = "server",
        port = "${port}",
        executable = {
            command = "dlv",
            args = { "dap", "-l", "127.0.0.1:${port}" },
        },
    }
end

vim.api.nvim_create_augroup("dap_dynamic_config", { clear = true })
-- TODO: Figure out how to reduce amount of tries to load launch.json while keeping it easy to use
vim.api.nvim_create_autocmd({ "BufEnter, BufWinEnter" }, {
    group = "dap_dynamic_config",
    callback = function()
        local vscode_dir = utils.find_upwards(".vscode")
        if vscode_dir == nil then
            return
        end
        if vim.fn.filereadable(vscode_dir .. "/launch.json") == 0 then
            return
        end
        require("dap.ext.vscode").load_launchjs(vscode_dir .. "/launch.json")
    end,
})

local function set_conditional_breakpoint()
    vim.ui.input({
        prompt = "Breakpoint condition: ",
    }, function(condition)
        dap.set_breakpoint(condition)
    end)
end

hydra({
    name = "Debug",
    mode = "n",
    body = "<leader>d",
    config = {
        invoke_on_body = true,
    },
    heads = {
        { "c", dap.continue,               { exit = true, desc = "run / [c]ontinue" } },
        { "b", dap.toggle_breakpoint,      { desc = "[b]reakpoint" } },
        { "B", set_conditional_breakpoint, { desc = "conditional [B]reakpoint" } },
        { "s", dap.step_into,              { desc = "[s]tep into" } },
        { "n", dap.step_over,              { desc = "[n]ext" } },
        { "u", dapui.toggle,               { exit = true, desc = "toddle [u]i" } },
    },
})
