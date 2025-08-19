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

local function err_msg(t)
    vim.notify('no template present matching ' .. t, vim.log.levels.WARN)
end

---@class TinyTemplatesCommands
return {
    ---defines the user commands
    ---@param core any
    setup = function(core)
        vim.api.nvim_create_user_command('TemplateApply', function(cmdargs)
            if cmdargs.bang == true then
                vim.cmd('%d')
            end
            if vim.fn.line('$') > 1 then return end
            for p, t in pairs(core.options.templates) do
                if cmdargs.args == p or vim.endswith(t, cmdargs.args) then
                    core.load_at(t)
                    return
                end
            end
            err_msg(cmdargs.args)
        end, { bang = true, nargs = 1, desc = 'Apply template if matching is present' })

        vim.api.nvim_create_user_command('TemplateAdd', function(cmdargs)
            for p, t in pairs(core.options.templates) do
                if cmdargs.args == p or vim.endswith(t, cmdargs.args) then
                    local _, line, _, _ = unpack(vim.fn.getpos('.'))
                    core.load_at(t, line - 1)
                    return
                end
            end
            err_msg(cmdargs.args)
        end, { nargs = 1, desc = 'Add template at cursor line' })
    end,
    ---removes the plugin commands
    unload = function()
        vim.api.nvim_del_user_command('TemplateApply')
        vim.api.nvim_del_user_command('TemplateAdd')
        package.loaded['tiny-templates.commands'] = nil
    end
}
