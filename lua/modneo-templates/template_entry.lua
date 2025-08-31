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

---@class Modneo.TemplatesReplaceRule

---the type used to represent template entries after the configuration has
---been loaded.
---@class Modneo.TemplatesTempateEntry
---@field [1] string
local M = {
    ---a list of replace rules
    replace = nil,
}

---@class Modneo.TemplatesTemplateEntryFactory
local F = {}

---creates a new template entry instance from the given value
---@param val any
---@return Modneo.TemplatesTempateEntry
F.new = function(val)
    if type(val) == 'string' then
        return vim.tbl_deep_extend('force', { val }, M)
    end


    if type(val) == "table" then
        if type(val[1]) ~= "string" then
            error("template config must start with filename at first position")
        end
        return vim.tbl_deep_extend('keep', val, M)
    end

    error("unexpected value in template config: type " .. type(val) .. " but only string and table allowed")
end

return F
