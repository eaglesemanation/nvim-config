local M = {}

local ls = require("luasnip")

local d = ls.dynamic_node
local sn = ls.sn
local i = ls.insert_node

-- Insert node that defaults to value of another insert node
M.i_rep = function(jump_index, node_reference)
    return d(jump_index, function(args)
        return sn(nil, {
            i(1, args[1]),
        })
    end, { node_reference })
end

-- Configure Luasnip
M.setup = function()
    vim.keymap.set({ "i", "s" }, "<C-j>", function()
        if ls.expand_or_jumpable() then
            ls.expand_or_jump()
        end
    end, { silent = true })

    vim.keymap.set({ "i", "s" }, "<C-k>", function()
        if ls.jumpable(-1) then
            ls.jump(-1)
        end
    end, { silent = true })

    vim.keymap.set({ "i", "s" }, "<C-l>", function()
        if ls.choice_active() then
            ls.change_choice(1)
        end
    end, { silent = true })

    local snippets_path = vim.fn.stdpath("config") .. "/snippets/"
    require("luasnip.loaders.from_lua").load({ paths = { snippets_path } })
end

return M
