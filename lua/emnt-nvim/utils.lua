local M = {}

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

return M
