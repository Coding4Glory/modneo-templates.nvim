--[[
modneo-templates.nvim
Copyright (C) 2025  Markus Hergenröder <markus@coding4glory.net>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]

---@class Modneo.TemplatesOptions
local defaults = {
    ---@type table
    ---a list of paths to search for templates, first template found will be used
    ---so list order is important
    include = {
        vim.fs.joinpath(vim.fn.stdpath('config'), 'templates'),
        vim.fs.joinpath(vim.fn.stdpath('data'), 'lazy', 'modneo-templates.nvim', 'templates')
    },
    ---@type table
    ---A table with patterns and template file names.
    ---Patterns should be file names containing wildcards
    ---e. g. `*.lua` or `ftplugin/*.vim`. 
    templates = {
        ['*.lua'] = 'skel.lua',
        ['ftplugin/*.vim'] = 'ftplugin.vim',
    },
    ---@type boolean
    ---can be set to true to prevent automatic template loading for new files.
    ---Defaults to false since this is the primary use case for this plugin.
    no_autoload = false,
}

---@class Modneo.TemplatesConfig
---@field options Modneo.TemplatesOptions
local M = {}

---@type function
---@return Modneo.TemplatesConfig
M.init = function()
    M.options = vim.tbl_deep_extend('keep', defaults, {})
    return M
end

---@param opts table table with user defined options
---@return Modneo.TemplatesOptions
M.setup = function(opts)
    M.options = vim.tbl_deep_extend('force', M.options or defaults, opts or {})
    return M.options
end

return M
