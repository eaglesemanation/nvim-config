local utils = require("emnt-nvim.utils")

local function has_k8s_keys()
    local query = [[
        (block_node(block_mapping
            (block_mapping_pair key: (_) @_vers_key (#eq? @_vers_key "apiVersion"))
            (block_mapping_pair key: (_) @_kind_key (#eq? @_kind_key "kind"))
            (block_mapping_pair
                key: (_) @_metadata_key (#eq? @_metadata_key "metadata")
                value: (block_node(block_mapping(
                    block_mapping_pair key: (_) @_name_key (#eq? @_name_key "name")
                )))
            )
        )) @k8s_manifest
    ]]
    return utils.has_ts_capture(query, "k8s_manifest")
end

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.yaml", "*.yml" },
    callback = function()
        local absolute_path = vim.api.nvim_buf_get_name(0)
        if absolute_path:match("[.]k8s[.]ya?ml$") or has_k8s_keys() then
            vim.api.nvim_buf_set_option(0, "ft", "yaml.kubernetes")
        end
    end,
})
