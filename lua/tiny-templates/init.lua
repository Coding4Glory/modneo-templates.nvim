--[[
modneo-templates init script
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
    init = function()
        if vim.go.tiny_templates_loaded == true then return end

        require('tiny-templates.config').init()
        require('tiny-templated.core').init()
        require('tiny-templates.commands').setup()
        vim.go.tiny_templates_loaded = true
    end,

	---@type function
	---initializes the module by setting up auto commands for configured file patterns
	---@param opts Modneo.TemplatesOptions
	setup = function(opts)
        require('tiny-templates.config').setup(opts)
        require('tiny-templates.core').init()
        if package.loaded['tiny-templates.commands'] == nil then
            require('tiny-templates.commands').setup()
        end
	end,
}
