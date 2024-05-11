local M = {}

local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local efm_config = require("emnt-nvim.efm-config")

local hydra = require("hydra")
local cmd = require("hydra.keymap-util").cmd

local schemastore = require("schemastore")
local schemas_path = vim.fn.stdpath("config") .. "/json-schemas/"

-- List of servers that will be enabled, either a boolean or a table with custom config
local servers = {
    yamlls = {
        settings = {
            yaml = {
                schemas = vim.list_extend({
                    kubernetes = { "*.k8s.yaml" },
                }, schemastore.yaml.schemas()),
            },
        },
        on_attach = function(_, bufnr)
            if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].filetype == "helm" then
                vim.diagnostic.disable()
            end
        end,
    },
    jsonls = {
        filetypes = { "json", "jsonc", "json5" },
        settings = {
            json = {
                schemas = schemastore.json.schemas({
                    extra = {
                        {
                            description = "VSCode launch.json schema",
                            fileMatch = ".vscode/launch.json",
                            name = "vscode-launch.json",
                            url = schemas_path .. "vscode-launch.json",
                        },
                    },
                }),
                validate = { enable = true },
            },
        },
    },
    jsonnet_ls = true,
    marksman = true,
    terraformls = true,
    clangd = {
        cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=never",
        },
    },
    cmake = true,
    rust_analyzer = {
        settings = {
            ["rust-analyzer"] = {
                checkOnSave = {
                    command = "clippy",
                },
            },
        },
    },
    gopls = {
        settings = {
            hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
            },
        },
    },
    pylsp = true,
    tsserver = true,
    nil_ls = true,
    -- Configured through nvim-jdtls
    jdtls = false,
    lua_ls = {
        settings = {
            Lua = {
                completion = { callSnippet = "Replace" },
                telemetry = { enable = false },
                workspace = { library = { "${3rd}/luassert/library" } },
            },
        },
    },
    efm = {
        filetypes = vim.tbl_keys(efm_config.languages),
        settings = {
            rootMarkers = { ".git/" },
            languages = efm_config.languages,
        },
        init_options = {
            documentFormatting = true,
            documentRangeFormatting = true,
        },
    },
    omnisharp = {
        cmd = { "OmniSharp" },
    },
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

local server_exists = function(server, config)
    local server_name = nil
    local default_cmd = lspconfig[server].document_config.default_config.cmd
    if default_cmd ~= nil then
        server_name = default_cmd[1]
    end
    if type(config) == "table" and config.cmd ~= nil and #config.cmd > 0 then
        server_name = config.cmd[1]
    end

    if server_name == nil then
        return false
    end
    return vim.fn.executable(server_name) == 1
end

local setup_server = function(server, config)
    if type(config) == "boolean" and not config then
        return
    end

    if not server_exists(server, config) then
        return
    end

    if type(config) ~= "table" then
        config = {}
    end

    config = vim.tbl_deep_extend("force", {
        capabilities = capabilities,
        flags = {
            debounce_text_changes = 50,
        },
    }, config)

    lspconfig[server].setup(config)
end

local function setup_servers()
    for server, config in pairs(servers) do
        setup_server(server, config)
    end
end

-- Diagnostics Config
local function setup_diagnostics()
    -- Set diganostic sign icons
    -- https://github.com/neovim/nvim-lspconfig/wiki/UI-customization#change-diagnostic-symbols-in-the-sign-column-gutter
    local signs = { Error = " ", Warning = " ", Hint = " ", Information = " " }
    for type, icon in pairs(signs) do
        local hl = "LspDiagnosticsSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end
end

local hydra_conf = {
    name = "LSP",
    mode = "n",
    body = "<leader>s",
    config = {
        -- Blue hydra dies as soon as any of it heads is called
        color = "blue",
    },
    heads = {
        { "f", vim.lsp.buf.format,                    { desc = "[f]ormat" } },
        { "d", cmd("Telescope lsp_definitions"),      { desc = "[d]efinitions" } },
        { "D", cmd("Telescope lsp_references"),       { desc = "references" } },
        { "i", cmd("Telescope lsp_implementations"),  { desc = "[i]mplementations" } },
        { "t", cmd("Telescope lsp_type_definitions"), { desc = "[t]ype definitions" } },
        { "e", vim.diagnostic.open_float,             { desc = "[e]rros (diagnostic)" } },
        { "h", vim.lsp.buf.hover,                     { desc = "[h]over popup" } },
        { "r", vim.lsp.buf.rename,                    { desc = "[r]ename" } },
        { "a", vim.lsp.buf.code_action,               { desc = "code [a]ction" } },
    },
}

M.check_health = function()
    for server, config in pairs(servers) do
        if type(config) == "boolean" and not config then
            goto continue
        end
        if server_exists(server, config) then
            vim.health.report_ok(server .. " installed")
        else
            vim.health.report_error(server .. " not installed")
        end
        ::continue::
    end
end

M.setup = function()
    -- Auto format on save
    vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        pattern = "*",
        callback = function()
            vim.lsp.buf.format()
        end,
    })
    setup_servers()
    setup_diagnostics()
    hydra(hydra_conf)
end

return M
