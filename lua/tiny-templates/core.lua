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

---@class TinyTemplates
---@field options TinyTemplateSettings
local M = {}

---loads the template according
---@param template string the template name to apply
---@param position any the range prefix for the read command, defaults to 0 for the beginning of the file
M.load_template = function(template, position)
    position = position or 0
    for _, p in ipairs(M.options.include) do
        local template_path = vim.fs.joinpath(p, template)
        if vim.uv.fs_stat(template_path) then
            vim.cmd(position .. "read " .. template_path)
            vim.b.tiny_template_added = template
            return
        end
    end
    vim.notify("Template: " .. template .. " not found", vim.log.levels.WARN)
end

---initialize the core module
M.init = function()
    M.options = require("tiny-templates.config").options

    local template_group = vim.api.nvim_create_augroup("tiny_templates", { clear = true })
    if M.options.no_autoload then
        return
    end

    for p, t in pairs(M.options.templates) do
        vim.api.nvim_create_autocmd({ "BufNewFile" }, {
            pattern = p,
            group = template_group,
            callback = function(args)
                M.load_template(t)
            end,
        })
    end

    return M
end

return M
