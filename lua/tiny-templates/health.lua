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

local function count_files(path)
    local file_counter = 0
    for _, type in vim.fs.dir(path, {}) do
        file_counter = file_counter + (type == 'file' and 1 or 0)
    end
    return file_counter
end

return {
    check = function()
        local options = require('tiny-templates.config').options
        local available_paths = 0
        for _, path in ipairs(options.include) do
            if vim.fn.isdirectory(path) == 1 then
                local files = count_files(path)
                vim.health.ok(path .. ' exists (' .. files .. ' files)')
                available_paths = available_paths + 1
            else
                vim.health.warn(path .. ' does not exist')
            end
        end
        if available_paths == 0 then
            vim.health.error('no template path available')
        end
    end
}
