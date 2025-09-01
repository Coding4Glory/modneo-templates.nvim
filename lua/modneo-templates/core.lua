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

---@class Modneo.Templates
---@field options Modneo.Templates.ConfigOptions
local M = {}

---tries to find the full path of the template file
---@param template string the filename of the template
---@return string|nil the path if found, otherwise nil
M.find = function(template)
    for _, p in ipairs(M.options.include) do
        local template_path = vim.fs.joinpath(p, template)
        if (vim.uv.fs_stat(template_path) or not_found).type == "file" then
            return template_path
        end
    end
    return nil
end

---loads the template at the given position
---@param template Modneo.Templates.Config.TempateEntry the template to apply
---@param position integer? the line to insert the template, defaults to 0 for first line
M.load_at = function(template, position)
    position = position or 0
    if type(template[1]) ~= "string" then
        vim.notify("template has no filename", vim.log.levels.ERROR)
        return
    end
    local template_path = M.find(template[1])
    if template_path ~= nil then
        if type(template_path) ~= "string" then
            error("path must be string")
        end
        vim.cmd(position .. "read " .. template_path)
        vim.b.tiny_template_added = template[1]
    else
        vim.notify("Template: " .. (template[1] or "n/a") .. " not found", vim.log.levels.WARN)
    end
end

local au_group_name = "modneo_templates"

---loads the given file into a temporary buffer and returns the id
---@param filename string file to load
---@return integer the id of the buffer
local function load_temp(filename)
    local tmp_buf = vim.api.nvim_create_buf(false, true)
    if type(filename) == "table" then
        error("filename cannot be table")
    end
    vim.api.nvim_buf_call(tmp_buf, function()
        vim.cmd("0read " .. filename)
    end)
    return tmp_buf
end

---replaces the given line with the contens from buffer and deletes the
---buffer afterwards
---@param lnum integer number of line to replace
---@param buf integer the number of the buffer with the content
---@param formatstring string? a string to format the buffer, usually the comment string
local function replace_line_with_buf(lnum, buf, formatstring)
    formatstring = vim.fn.printf(formatstring or "%s", "\\1")
    formatstring = vim.fn.substitute(formatstring, "/", "\\/", "")

    vim.api.nvim_buf_call(buf, function()
        vim.cmd("%s/\\(.*\\)/" .. formatstring)
    end)
    local replacement = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local curbuf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(curbuf, lnum, lnum + 1, true, replacement)
    vim.api.nvim_buf_delete(buf, { force = true })
end

---replaces the line containing *what* with the contents of filename
---@param what string
---@param filename string
local function replace_from_file(what, filename)
    local tmp_buf = load_temp(filename)
    local comment_string = vim.bo.commentstring or vim.o.commentstring or ""
    local commented = what
    if comment_string ~= nil and comment_string ~= "" then
        commented = vim.fn.printf(comment_string, what)
    end

    local current_line_nr = 1
    while current_line_nr < vim.api.nvim_buf_line_count(tmp_buf) do
        local line = vim.fn.getbufoneline(tmp_buf, current_line_nr)
        if line == commented then
            replace_line_with_buf(current_line_nr, tmp_buf, comment_string)
            return
        end
        if line:match(what) then
            replace_line_with_buf(current_line_nr, tmp_buf)
            return
        end

        current_line_nr = current_line_nr + 1
    end
end

---performs the replacement
---@param what string the pattern to replace
---@param with string string or other template
M.replace = function(what, with)
    if type(what) == "table" then
        error("what cannot be table")
    end
    if type(with) == "table" then
        error("with cannot be table")
    end
    local other_template = M.find(with)
    if other_template == nil then
        vim.cmd("%s/" .. what .. "/" .. with .. "/g")
        return
    end
    replace_from_file(what, other_template)
end

---initialize the core module
---@return Modneo.Templates
M.init = function()
    M.options = require("modneo-templates.config").options

    local template_group = vim.api.nvim_create_augroup(au_group_name, { clear = true })

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

M.unload = function()
    vim.api.nvim_del_augroup_by_name(au_group_name)
end

return M
