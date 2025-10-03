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

---@class Modneo.Templates.Config.ReplaceContext
---@field template string? the name of the template originally loaded
---@field pattern string the pattern to replace
---@field silent boolean tells if messages shall be supressed

---@alias Modneo.Templates.Config.ReplaceRule.Kind
---| 'command' ensures the value will be treated as command
---| 'file' ensures the value will be treated as file
---| 'multiline' overrides the default behaviour for tables to append a multiline string
---| 'system' ensures the value will be treated as system command
---| 'string' ensures the value will be treated as simple string
---| 'callback' not require to be specified, will always be detected correctly

---@class Modneo.Templates.Config.ReplaceRule
---@field [1] string the pattern to search for replacement
---@field [2] string|string[]|fun(ctx:Modneo.Templates.Config.ReplaceContext):string|string[]|nil the {rhs} for the replacement if function did not perform the replacement already
---@field [3] Modneo.Templates.Config.ReplaceRule.Kind? can be used to force a specific kind if auto detection fails or is not desired

---the type used to represent template entries after the configuration has
---been loaded.
---@class Modneo.Templates.Config.TemplateEntry
---@field [1] string
---@field replace  Modneo.Templates.Config.ReplaceRule|Modneo.Templates.Config.ReplaceRule[]

---@class Modneo.Templates.Config.TemplateEntryFactory
local F = {}

---creates a new template entry instance from the given value
---@param val any
---@return Modneo.Templates.Config.TemplateEntry
F.new = function(val)
    if type(val) == 'string' then
        return { val }
    end

    -- TODO: replace errors with warning
    if type(val) == 'table' then
        if type(val[1]) ~= 'string' then
            error(
                'template rule must start with filename at first indexed position'
            )
        end
        if (val.replace ~= nil and type(val.replace) ~= 'table') then
            error("replace config must be a rule or list or rules got " .. vim.inspect(vim.replace))
            local check_val = type(val.replace[1])
            if check_val ~= 'string' and check_val ~= 'table' then
                error("invalid replace rule")
            end
        end
        return val
    end

    error(
        'unexpected value in template config: type '
            .. type(val)
            .. ' but only string and Modneo.TemplatesTempateEntry allowed'
    )
end

return F
