local M = {}

local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

local hydra = require("hydra")
local cmd = require("hydra.keymap-util").cmd

local schemastore = require("schemastore")

local efm_fs = require("efmls-configs.fs")

local prettier_d = require("efmls-configs.formatters.prettier_d")
local eslint_d = require("efmls-configs.linters.eslint_d")
local stylelint = require("efmls-configs.linters.stylelint")
local stylua = require("efmls-configs.formatters.stylua")
local terraform_fmt = require("efmls-configs.formatters.terraform_fmt")
local golangci_lint = require("efmls-configs.linters.golangci_lint")
local shellcheck = require("efmls-configs.linters.shellcheck")
local alejandra = require("efmls-configs.formatters.alejandra")
local statix = require("efmls-configs.linters.statix")

-- Avoid forcing editor config on parameters that are controlled by formatter config
prettier_d.formatCommand = string.format(
    "%s '${INPUT}' ${--range-start=charStart} ${--range-end=charEnd}",
    efm_fs.executable("prettierd", efm_fs.Scope.NODE)
)

local efm_languages = {
    yaml = { prettier_d },
    json = { prettier_d },
    html = { prettier_d },
    css = { prettier_d, stylelint },
    typescript = { eslint_d, prettier_d },
    typescriptreact = { eslint_d, prettier_d },
    javascript = { eslint_d, prettier_d },
    javascriptreact = { eslint_d, prettier_d },
    lua = { stylua },
    terraform = { terraform_fmt },
    go = { golangci_lint },
    sh = { shellcheck },
    bash = { shellcheck },
    nix = { alejandra, statix },
}

-- LSP Config
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
    },
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
        filetypes = vim.tbl_keys(efm_languages),
        settings = {
            rootMarkers = { ".git/" },
            languages = efm_languages,
        },
        init_options = {
            documentFormatting = true,
            documentRangeFormatting = true,
        },
    },
    rnix = true,
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

local server_exists = function(server, config)
    local server_name = lspconfig[server].document_config.default_config.cmd[1]
    if type(config) == "table" and config.cmd ~= nil and #config.cmd > 0 then
        server_name = config.cmd[1]
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
        { "f", vim.lsp.buf.format, { desc = "[f]ormat" } },
        { "d", cmd("Telescope lsp_definitions"), { desc = "[d]efinitions" } },
        { "D", cmd("Telescope lsp_references"), { desc = "references" } },
        { "t", cmd("Telescope lsp_type_definitions"), { desc = "[t]ype definitions" } },
        { "e", vim.diagnostic.open_float, { desc = "[e]rros (diagnostic)" } },
        { "h", vim.lsp.buf.hover, { desc = "[h]over popup" } },
        { "r", vim.lsp.buf.rename, { desc = "[r]ename" } },
        { "a", vim.lsp.buf.code_action, { desc = "code [a]ction" } },
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
    --for _, lang in pairs(efm_languages) do
    --    if null_ls_source_exists(source) then
    --        vim.health.report_ok(source._opts.command .. " installed")
    --    else
    --        vim.health.report_error(source._opts.command .. " not installed")
    --    end
    --end
end

M.setup = function()
    -- Auto format on save
    vim.cmd([[autocmd BufWritePre * lua vim.lsp.buf.format()]])
    setup_servers()
    setup_diagnostics()
    hydra(hydra_conf)
end

return M
