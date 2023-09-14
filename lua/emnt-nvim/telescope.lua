local telescope = require("telescope")
local actions = require("telescope.actions")
local builtin = require("telescope.builtin")
local extensions = telescope.extensions

local todo = require("todo-comments")

local hydra = require("hydra")

todo.setup({})

telescope.setup({
    defaults = {
        mappings = {
            i = {
                ["<esc>"] = actions.close,
            },
        },
    },
    pickers = {
        lsp_code_actions = {
            theme = "cursor",
        },
    },
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
        ["file_browser"] = {
            hijack_netrw = true,
        },
    },
})

telescope.load_extension("fzf")
telescope.load_extension("file_browser")
telescope.load_extension("project")
telescope.load_extension("todo-comments")

hydra({
    name = "Find",
    mode = "n",
    body = "<leader>f",
    config = {
        -- Blue hydra dies as soon as any of it heads is called
        color = "blue",
    },
    heads = {
        -- File pickers
        {
            "f",
            function()
                builtin.find_files({ hidden = true })
            end,
            { desc = "project [f]iles" },
        },
        {
            "g",
            function()
                builtin.live_grep({ additional_args = { "--hidden" } })
            end,
            { desc = "[g]rep" },
        },
        {
            "b",
            function()
                extensions.file_browser.file_browser({ cwd = vim.fn.expand("%:p:h") })
            end,
            { desc = "[b]rowser" },
        },
        { "B", builtin.buffers, { desc = "[B]uffers" } },
        { "s", builtin.treesitter, { desc = "[s]ymbols" } },
        {
            "p",
            function()
                extensions.project.project({ display_type = "full" })
            end,
            { desc = "[p]rojects" },
        },
        { "d", builtin.diagnostics, { desc = "[d]iagnostics" } },
        {
            "t",
            function()
                extensions["todo-comments"].todo()
            end,
            { desc = "[t]odo" },
        },
    },
})
