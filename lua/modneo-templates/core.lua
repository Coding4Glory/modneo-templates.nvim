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

---@class Modneo.Templates
---@field options Modneo.TemplatesOptions
local M = {}

---tries to find the full path of the template file
---@param template string the filename of the template
---@return string|nil the path if found, otherwise nil
M.find = function(template)
	for _, p in ipairs(M.options.include) do
		local template_path = vim.fs.joinpath(p, template)
		if vim.uv.fs_stat(template_path) then
			return template_path
		end
	end
	return nil
end

---loads the template according
---@param template string the template name to apply
---@param position integer? the line to insert the template, defaults to 0 for first line
M.load_at = function(template, position)
	position = position or 0
	local template_path = M.find(template)
	if template_path ~= nil then
		vim.cmd(position .. "read " .. template_path)
		vim.b.tiny_template_added = template
	else
		vim.notify("Template: " .. template .. " not found", vim.log.levels.WARN)
	end
end

---initialize the core module
---@return Modneo.Templates
M.init = function()
	M.options = require("modneo-templates.config").options

	local template_group = vim.api.nvim_create_augroup("tiny_templates",
        { clear = true })

	if M.options.no_autoload then
		return M
	end

	for p, t in pairs(M.options.templates) do
		vim.api.nvim_create_autocmd("BufNewFile", {
			pattern = p,
			group = template_group,
			callback = function(args)
				M.load_at(t)
			end,
		})
		vim.api.nvim_create_autocmd("BufRead", {
			pattern = p,
			group = template_group,
			callback = function(args)
				if vim.api.nvim_get_option_value("modifiable", { buf = args.buf }) == false then
					return
				end
				if vim.api.nvim_buf_line_count(args.buf) > 1 then
					return
				end
				M.load_at(t)
			end,
		})
	end

	return M
end

return M
