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

vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DapBreakpoint' })
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

local hint = [[
     ^ ^Step^ ^ ^      ^ ^     Action
 ----^-^-^-^--^-^----  ^-^-------------------
     ^ ^back^ ^ ^     ^_t_: toggle breakpoint
     ^ ^ _K_^ ^        _T_: clear breakpoints
 out _H_ ^ ^ _L_ into  _c_: continue
     ^ ^ _J_ ^ ^       _x_: terminate
     ^ ^over ^ ^     ^^_u_: open UI

     ^ ^  _q_: exit
]]

hydra({
    name = "Debug",
    mode = "n",
    body = "<leader>d",
    hint = hint,
    config = {
        invoke_on_body = true,
        color = "pink",
        hint = { type = "window" },
    },
    heads = {
        { 'H', dap.step_out,          { desc = 'step out' } },
        { 'J', dap.step_over,         { desc = 'step over' } },
        { 'K', dap.step_back,         { desc = 'step back' } },
        { 'L', dap.step_into,         { desc = 'step into' } },
        { 't', dap.toggle_breakpoint, { desc = 'toggle breakpoint' } },
        { 'T', dap.clear_breakpoints, { desc = 'clear breakpoints' } },
        { 'c', dap.continue,          { desc = 'continue' } },
        { 'x', dap.terminate,         { desc = 'terminate' } },
        { 'u', dapui.toggle,          { exit = true, desc = 'toggle ui' } },
        { 'q', nil,                   { exit = true, nowait = true, desc = 'exit' } },
    },
})
