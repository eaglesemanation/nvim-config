local M = {}

local ts_parsers = require("nvim-treesitter.parsers")

M.vscode_extensions_path = function()
    for _, ext_path in pairs({ "~/.nix-profile/share/vscode/extensions", "~/.vscode/extensions" }) do
        local abs_ext_path = vim.fs.normalize(ext_path)
        if vim.fn.isdirectory(abs_ext_path) then
            return abs_ext_path
        end
    end
    return nil
end

M.project_root_path = function()
    local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null")
    git_root = git_root:gsub("\n$", "")
    if git_root == "" then
        return ""
    end
    -- Convert from full path to dir name
    git_root = vim.fn.fnamemodify(git_root, ":t")
    return "[git: " .. git_root .. "] "
end

--- Takes a treesitter query and looks within current window
--- to see if query applied to root will return required capture
---
---@param query string
---@param capture_name string
---@param buf buffer | nil
---@return boolean
M.has_ts_capture = function(query, capture_name, buf)
    if not buf then
        buf = 0
    end
    local ft = vim.api.nvim_buf_get_option(buf, "ft")
    local lang = ts_parsers.ft_to_lang(ft)
    local lang_tree = ts_parsers.get_parser(buf, lang)
    if not lang_tree then
        return false
    end
    local root = nil
    for _, tree in pairs(lang_tree:trees()) do
        root = tree:root()
        if root then
            break
        end
    end
    if not root then
        return false
    end

    local query_obj = vim.treesitter.query.parse(lang, query)
    ---@diagnostic disable-next-line:missing-parameter 
    for id in query_obj:iter_captures(root, buf) do
        if query_obj.captures[id] == capture_name then
            return true
        end
    end
end

return M
