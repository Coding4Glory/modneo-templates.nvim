--[[
modneo-templates
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

---@class Modneo.TemplatesPlugin
return {
    ---initializes the plugin
    init = function()
        if vim.g.tiny_templates_loaded == true then return end

        require('modneo-templates.config').init()
        require('modneo-templates.core').init()
        require('modneo-templates.commands').setup()
        vim.g.tiny_templates_loaded = true
    end,

    ---Initializes the module by setting up auto commands for configured files
    ---patterns.
    ---@param opts Modneo.TemplatesOptions
    setup = function(opts)
        require('modneo-templates.config').setup(opts)
        require('modneo-templates.core').init()
        if package.loaded['modneo-templates.commands'] == nil then
            require('modneo-templates.commands').setup()
        end
    end,

    ---Removes the auto commands and user commands so effectivately removes
    ---the plugin.
    unload = function()
        require('modneo-templates.commands').unload()
        require('modneo-templates.core').unload()
        for _, mod in ipairs({
            'modneo-templates.core',
            'modneo-templates.common',
            'modneo-templates.commands',
            'modneo-templates.health',
            'modneo-templates.config',
            'modneo-templates.template_entry',
            'modneo-templates',
        }) do
            if package.loaded[mod] ~= nil then
                package.loaded[mod] = nil
            end
        end
    end
}
