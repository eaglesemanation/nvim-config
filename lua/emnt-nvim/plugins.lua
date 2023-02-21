local function emntMod(name)
    return function()
        require("emnt-nvim." .. name)
    end
end

local plugins = {
    ----
    -- Movements
    ----
    "tpope/vim-surround",
    "tpope/vim-repeat",
    -- Additional targets that feel like vanilla vim
    "wellle/targets.vim",
    {
        -- Move to any visible position in 4 keystrokes max
        "ggandor/leap.nvim",
        config = function()
            require("leap").add_default_mappings()
        end,
    },
    -- Add custom modes
    "anuvyklack/hydra.nvim",
    -- Draw diagrams
    {
        "jbyuki/venn.nvim",
        config = emntMod("venn"),
    },

    -- Fuzzy search
    {
        "nvim-telescope/telescope.nvim",
        name = "telescope",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            { "nvim-telescope/telescope-fzf-native.nvim",  build = "make" },
            { "nvim-telescope/telescope-ui-select.nvim" },
            { "nvim-telescope/telescope-file-browser.nvim" },
            { "nvim-telescope/telescope-project.nvim" },
            { "folke/todo-comments.nvim" }
        },
        config = emntMod("telescope"),
    },

    { "lifepillar/vim-solarized8", lazy = true },
    -- Changes background color of RGB values
    {
        "norcalli/nvim-colorizer.lua",
        ft = { "css", "html" },
        config = true,
    },
    -- Automatically generates LSP colors for legacy colorschemes
    "folke/lsp-colors.nvim",
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            { "kyazdani42/nvim-web-devicons" },
        },
        opts = {},
    },
    -- Keep cursor position when window below is opened
    {
        "luukvbaal/stabilize.nvim",
        config = true,
    },

    ----
    -- Git integration
    ----
    "tpope/vim-fugitive",
    "tpope/vim-git",
    {
        "lewis6991/gitsigns.nvim",
        config = true,
    },
    {
        "sindrets/diffview.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
    },

    -- Simplified language servers config
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            -- Progress bar for language server indexing
            {
                "j-hui/fidget.nvim",
                opts = {
                    window = { blend = 0 },
                },
            },
            -- Configures lua language server for neovim specific api
            {
                "folke/neodev.nvim",
                config = true,
            },
            -- Autocompletion integration
            { "hrsh7th/cmp-nvim-lsp" },
        },
        config = function()
            require("emnt-nvim.lsp").setup()
        end,
    },
    -- Integration layer between linters/formatters and LSP
    "jose-elias-alvarez/null-ls.nvim",

    -- Task executor
    {
        "stevearc/overseer.nvim",
        config = true,
    },
    -- Debugger
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            { "rcarriga/nvim-dap-ui" },
        },
        config = emntMod("dap"),
    },

    -- Java specific LSP and DAP configuration with additional features
    {
        "mfussenegger/nvim-jdtls",
        ft = { "java" },
        config = function()
            require("emnt-nvim.jdtls").setup()
        end,
    },

    -- Testing frameworks integration
    {
        "nvim-neotest/neotest",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            { "nvim-neotest/neotest-go" },
            { "rouge8/neotest-rust" },
        },
        config = emntMod("neotest"),
    },

    -- Improved syntax support
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            -- Keep current context at the top of buffer (for example function name)
            { "nvim-treesitter/nvim-treesitter-context" },
            -- Interactive playground for treesitter queries
            { "nvim-treesitter/playground" },
        },
        build = function()
            require("nvim-treesitter.install").update({ with_sync = true })
        end,
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = "all",
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
            })
            require("treesitter-context").setup()
        end,
    },
    {
        "towolf/vim-helm",
        ft = { "helm" }
    },

    -- Snippets
    {
        "L3MON4D3/LuaSnip",
        config = emntMod("snippets"),
    },
    -- Autocompletion
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            { "hrsh7th/cmp-path" },
            { "hrsh7th/cmp-omni" },
            { "saadparwaiz1/cmp_luasnip" },
            { "onsails/lspkind.nvim" },
        },
        config = emntMod("completion"),
    },

    -- LaTeX integration
    {
        "lervag/vimtex",
        ft = { "tex" },
        config = function()
            vim.g.vimtex_view_method = "general"
            vim.g.vimtex_view_general_viewer = "evince"

            vim.g.vimtex_compiler_method = "latexmk"
            -- https://github.com/neovim/neovim/issues/12544
            vim.api.nvim_set_var("vimtex_compiler_latexmk", { build_dir = "./build" })

            vim.api.nvim_create_augroup("VimTeX", { clear = true })
            vim.api.nvim_create_autocmd("FileType", {
                group = "VimTeX",
                pattern = { "tex" },
                callback = function()
                    require("cmp").setup.buffer({ sources = { { name = "omni" } } })
                end,
            })
        end,
    },
}

require("lazy").setup(plugins)
