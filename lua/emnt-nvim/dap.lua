local dap = require("dap")
local dap_vscode = require("dap.ext.vscode")
local dapui = require("dapui")
local hydra = require("hydra")
local overseer = require("overseer")

local utils = require("emnt-nvim.utils")

local extensions_path = utils.vscode_extensions_path()

-- Use default config for now
dapui.setup()
overseer.setup({
    component_aliases = {
        default_vscode = {
            "default",
            "on_output_summarize",
            "on_result_diagnostics",
            "on_result_diagnostics_quickfix",
        }
    }
})

-- Support for JSON5
dap_vscode.json_decode = require("overseer.json").decode

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

local function load_launch_json()
    local vscode_dirs = vim.fs.find(".vscode",
        { upward = true, type = "directory", path = vim.fn.getcwd(), limit = math.huge })
    for _, vscode_dir in ipairs(vscode_dirs) do
        local launch_file = vscode_dir .. "/launch.json"
        if vim.fn.filereadable(launch_file) ~= 0 then
            dap_vscode.load_launchjs(launch_file)
        end
    end
end

-- Try loading on startup as well
load_launch_json()

vim.api.nvim_create_augroup("dap_dynamic_config", { clear = true })
vim.api.nvim_create_autocmd({ "DirChanged" }, {
    group = "dap_dynamic_config",
    callback = load_launch_json,
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
