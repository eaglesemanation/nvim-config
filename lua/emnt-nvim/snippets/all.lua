require("luasnip.session.snippet_collection").clear_snippets("all")

local ls = require("luasnip")

local s = ls.s
local f = ls.function_node

ls.add_snippets("all", {
    s(
        "uuid",
        f(function()
            local uuid = vim.fn.system("uuidgen")
            return string.sub(uuid, 1, -2)
        end)
    ),
})
