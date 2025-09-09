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

local not_found = { type = "n/a" }

local function get_added_template()
    return vim.b.modneo_template_added
end

---@param path string
local function set_added_template(path)
    vim.b.modneo_template_added = path
end

---@class Modneo.Templates
---@field options Modneo.Templates.ConfigOptions
local M = {}

---tries to find the full path of the template file
---@param filename string simple filename of the template or relative path from include directory
---@return string|nil the path if found, otherwise nil
M.find = function(filename)
    if vim.fs.abspath(filename) == filename then
        if (vim.uv.fs_stat(filename) or not_found).type == "file" then
            return filename
        end
        return nil
    end

    for _, p in ipairs(M.options.include) do
        local template_path = vim.fs.joinpath(p, filename)
        if (vim.uv.fs_stat(template_path) or not_found).type == "file" then
            return template_path
        end
    end
    return nil
end

---loads the template at the given position
---@param template Modneo.Templates.Config.TemplateEntry the template to apply
---@param position integer? the line to insert the template, defaults to 0 for first line
M.load_at = function(template, position)
    position = position or 0
    if type(template[1]) ~= "string" then
        vim.notify("template has no filename", vim.log.levels.ERROR)
        return
    end
    local template_path = M.find(template[1])
    if template_path ~= nil then
        vim.cmd(position .. "read " .. template_path)
        set_added_template(template_path)
        if template.replace ~= nil then
            if type(template.replace[1]) == 'string' then
                M.replace(template.replace)
                return
            end
            for _, r in ipairs(template.replace) do
                M.replace(r --[[@as Modneo.Templates.Config.ReplaceRule]])
            end
        end
    else
        vim.notify("Template: " .. (template[1] or "n/a") .. " not found", vim.log.levels.WARN)
    end
end

local au_group_name = "modneo_templates"

---sanitizes a string before pattern usage
---@param str string
---@return string
local function sanitize_for_pattern(str)
    return vim.fn.substitute(str, "/", "\\\\/", "g")
end

local function get_search_pattern(pattern)
    local commentstring = vim.bo.commentstring or "%s"
    local format_parts = vim.split(commentstring, "%s", { trimempty = true })
    if #format_parts == 0 then
        return sanitize_for_pattern(pattern)
    end
    if #format_parts == 1 then
        ---@diagnostic disable-next-line
        return sanitize_for_pattern(vim.fn.printf("\\(?:%s\\)\\?%s", format_parts[1], pattern))
    end
    if #format_parts == 2 then
        ---@diagnostic disable-next-line
        return sanitize_for_pattern(vim.fn.printf("\\(?:%s\\)\\?%s\\(?:%s\\)\\?", format_parts[1], pattern, format_parts[2]))
    end

end

---loads the given file into a temporary buffer and returns the id
---@param filename string file to load
---@return integer the id of the buffer
local function load_temp(filename)
    if vim.fs.abspath(filename) ~= filename then
        error('absolute path expected, got ' .. filename)
    end
    local tmp_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_call(tmp_buf, function()
        vim.cmd("0read " .. filename)
    end)
    return tmp_buf
end

---replaces the given line with the contens from buffer and deletes the
---buffer afterwards
---@param lnum integer number of line to replace
---@param buf integer the number of the buffer with the content
local function replace_line_with_buf(lnum, buf)
    local commentstring = vim.bo.commentstring or "%s"
    if commentstring == "" then
        commentstring = "%s"
    end
    local formatstring = sanitize_for_pattern(vim.fn.printf(commentstring, "\\1"))
    vim.api.nvim_buf_call(buf, function()
        vim.cmd("%s/\\(.*\\)/" .. formatstring)
    end)
    local replacement = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local curbuf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(curbuf, lnum - 1, lnum, true, replacement)
    vim.api.nvim_buf_delete(buf, { force = true })
end

---replaces the line containing *what* with the contents of filename
---@param pattern string
---@param filename string
local function replace_from_file(pattern, filename)
    local filepath = M.find(filename)
    if filepath == nil then
        error('template with name ' .. filename .. ' not found')
    end
    local search_pattern = get_search_pattern(pattern)
    local lnum = vim.fn.search(search_pattern, 'cn')
    if lnum > 0 then
        local tmp_buf = load_temp(filepath)
        replace_line_with_buf(lnum, tmp_buf)
    end
end


---determines the kind of the rule
---@param rule Modneo.Templates.Config.ReplaceRule
---@return Modneo.Templates.Config.ReplaceRule.Kind
---if the returned type is file, the second value is replaced with the absolute path
local function determin_rule_type(rule)
    if #rule == 3 then
        if type(rule[3]) ~= 'string' then
            error('Third element in replacement rule must be a string. See Modneo.Templates.Config.ReplaceRule.Kind')
        end
        return rule[3]
    end

    if type(rule[2]) == 'function' then
        return 'callback'
    end

    if type(rule[2]) == 'table' then
        return 'system'
    end

    if type(rule[2]) ~= 'string' then
        error('second value in rule is expected to be string, list of strings or callback')
    end

    ---@diagnostic disable-next-line
    if rule[2]:match('^:.*') ~= nil then
        return 'command'
    end

    local other_template = M.find(rule[2] --[[@as string]])
    if other_template ~= nil then
        rule[2] = other_template
        return 'file'
    end

    return 'string'
end

--#region replace_case

---@type table<Modneo.Templates.Config.ReplaceRule.Kind,fun(ctx:Modneo.Templates.Config.ReplaceContext,rhs:any)>
local replace_case = {}
replace_case['command'] = function(_, rhs)
    local cmd = rhs:match('[^:].*')
    local success, err = pcall(function(c) vim.cmd(c) end, cmd)
    if not success then
        print('substitution failed: ' .. err)
    end
end
replace_case['file'] = function(ctx, rhs)
    replace_from_file(ctx.pattern, rhs)
end
replace_case['string'] = function(ctx, rhs)
    local subst_command = '%s/' .. sanitize_for_pattern(ctx.pattern)
    .. '/' .. sanitize_for_pattern(rhs) .. '/g'
    replace_case['command'](ctx, subst_command)
end
replace_case['multiline'] = function(ctx, rhs)
    local tmp_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(tmp_buf, 0, -1, false, rhs)
    replace_line_with_buf(vim.fn.search(ctx.pattern), tmp_buf)
end
replace_case['system'] = function(ctx, rhs)
    local result = vim.system(rhs, { text = true }):wait()
    if result.code == 0 then
        local content = vim.split(result.stdout:gsub('\n$', ''), '\n', { trimempty = false })
        if #content > 1 then
            replace_case['multiline'](ctx, content)
            return
        end
        replace_case['string'](ctx, result.stdout)
        return
    end
    vim.print("command '" ..
        table.concat(rhs, ' ') ..
        "' ended in: " ..
        result.stderr)
end
replace_case['callback'] = function(ctx, rhs)
    local result = rhs(ctx)
    if type(result) == 'string' then
        replace_case['string'](ctx, result)
    elseif type(result) == 'table' and type(result[1]) == 'string' then
        replace_case['multiline'](ctx, result)
    end
end

--#endregion replace_case

---performs the replacement
---@param rule Modneo.Templates.Config.ReplaceRule
M.replace = function(rule)
    local kind = determin_rule_type(rule)
    ---@type Modneo.Templates.Config.ReplaceContext
    local ctx = {
        template = get_added_template(),
        pattern = rule[1]
    }
    if replace_case[kind] == nil then
        error('replacement rule kind ' .. (kind or 'nil') .. ' not supported')
    end
    replace_case[kind](ctx, rule[2])
end

---initialize the core module
---@return Modneo.Templates
M.init = function()
    M.options = require("modneo-templates.config").options
    if M.options == nil then
        error("configuration not initialized")
    end

    local template_group = vim.api.nvim_create_augroup(au_group_name, { clear = true })

    if M.options.no_autoload then
        return M
    end

    for p, t in M.options.templates_iter() do
        vim.api.nvim_create_autocmd("BufNewFile", {
            pattern = p,
            group = template_group,
            callback = function()
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
                if string.len(vim.fn.getline(1)) > 0 then
                    return
                end
                M.load_at(t)
            end,
        })
    end

    return M
end

M.unload = function()
    vim.api.nvim_del_augroup_by_name(au_group_name)
end

return M
