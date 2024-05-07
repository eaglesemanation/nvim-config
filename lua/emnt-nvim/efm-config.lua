local M = {}

local efm_fs = require("efmls-configs.fs")

local prettier_d = require("efmls-configs.formatters.prettier_d")
local dprint_d = require("efmls-configs.formatters.dprint")
local eslint_d = require("efmls-configs.linters.eslint_d")
local stylelint = require("efmls-configs.linters.stylelint")
local stylua = require("efmls-configs.formatters.stylua")
local terraform_fmt = require("efmls-configs.formatters.terraform_fmt")
local nixfmt = require("efmls-configs.formatters.nixfmt")
local golangci_lint = require("efmls-configs.linters.golangci_lint")
local shellcheck = require("efmls-configs.linters.shellcheck")
local statix = require("efmls-configs.linters.statix")

-- Avoid forcing editor config on parameters that are controlled by formatter config
prettier_d.formatCommand = string.format(
    "%s '${INPUT}' ${--range-start=charStart} ${--range-end=charEnd}",
    efm_fs.executable("prettierd", efm_fs.Scope.NODE)
)

golangci_lint.rootMarkers = { ".golangci.yml", ".golangci.yaml", ".golangci.toml", ".golangci.json", "go.mod" }
golangci_lint.lintWorkspace = true
golangci_lint.lintFormats = { "%f:%l:%c %m" }

M.languages = {
    yaml = { prettier_d },
    json = { dprint_d },
    html = { prettier_d },
    css = { prettier_d, stylelint },
    typescript = { prettier_d, eslint_d },
    typescriptreact = { prettier_d, eslint_d },
    javascript = { prettier_d, eslint_d },
    javascriptreact = { prettier_d, eslint_d },
    lua = { stylua },
    terraform = { terraform_fmt },
    go = { golangci_lint },
    sh = { shellcheck },
    bash = { shellcheck },
    nix = { nixfmt, statix },
}

return M
