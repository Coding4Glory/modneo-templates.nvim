local defaults = {
    -- TODO: add data path and lazy path if existing
    include = { vim.fs.joinpath(vim.fn.stdpath('config'), 'templates') },
    templates = {
        ['*.lua'] = 'skel.lua',
        ['ftplugin/*.vim'] = 'ftplugin.vim',
    }
}

---@class TemplateConfig
local M = {}

---@class TemplateSettings
---@field include table a list with paths to search for templates
---@field templates table a table with template mappings
M.config = {}

---@type function
---@param opts table table with user defined options
M.setup = function(opts)
    M.config = vim.tbl_deep_extend('force', defaults, opts or {})
    return M.config
end

return M
