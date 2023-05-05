local M = {}

M.find_upwards = function(match, opts)
    local match_names = {}
    if type(match) == "table" then
        match_names = match
    else
        match_names[1] = match
    end

    if opts == nil then
        opts = {}
    end
    if opts.path == nil then
        opts.path = vim.fn.getcwd()
    end

    local targets = {}
    table.insert(targets, opts.path)
    for parent in vim.fs.parents(opts.path) do
        table.insert(targets, parent)
    end

    for _, target in pairs(targets) do
        for name, type in vim.fs.dir(target) do
            if opts.type ~= nil and type ~= opts.type then
                goto continue
            end
            for _, match_name in pairs(match_names) do
                if name == match_name then
                    return target .. "/" .. name
                end
            end
            ::continue::
        end
    end
    return nil
end

M.vscode_extensions_path = function()
    for _, ext_path in pairs({ "~/.nix-profile/share/vscode/extensions", "~/.vscode/extensions" }) do
        local abs_ext_path = vim.fs.normalize(ext_path)
        if vim.fn.isdirectory(abs_ext_path) then
            return abs_ext_path
        end
    end
    return nil
end

return M
