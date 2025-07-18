--[[
tiny-templates.nvim
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

local defaults = {
    include = {
        vim.fs.joinpath(vim.fn.stdpath('config'), 'templates'),
        vim.fs.joinpath(vim.fn.stdpath('data'), 'lazy', 'tiny-templates.nvim', 'templates')
    },
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
