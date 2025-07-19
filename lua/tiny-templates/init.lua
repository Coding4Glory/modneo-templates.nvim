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

---loads the template according
---@param include_paths string[] the paths to search for templates in order
---@param template string the template name to apply
local function load_template(include_paths, template)
     for _, p in ipairs(include_paths) do
        local template_path = vim.fs.joinpath(p, template)
        if vim.uv.fs_stat(template_path) then
            vim.cmd('0read' .. template_path)
            return
        end
    end
end

---@class TinyTemplates
return {
    ---@type function 
    ---initializes the module by setting up auto commands for configured file patterns
    ---@param opts TinyTemplateSettings
    setup = function(opts)
        local settings = require('tiny-templates.config').init(opts)
        local template_group = vim.api.nvim_create_augroup('tiny_templates', { clear = true, })
        for p, t in pairs(settings.templates) do
            vim.api.nvim_create_autocmd({ 'BufNewFile' },
                {
                    pattern = p,
                    group = template_group,
                    callback = function() load_template(settings.include, t) end
                })
        end
    end
}

