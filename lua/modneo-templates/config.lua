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

---contains the default path for builtin templates when installed with lazy
local builtin_templates = vim.fs.joinpath(
    vim.fn.stdpath('data'),
    'lazy',
    'modneo-templates.nvim',
    'templates'
)

---contains the default path for user templates
local user_templates = vim.fs.joinpath(
    vim.fn.stdpath('config'),
    'templates'
)

---@class Modneo.Templates.ConfigOptions
---@field templates_iter Iterator<string,Modneo.Templates.ConfigOptions>?
local defaults = {
    ---a list of paths to search for templates, first template found will be used
    ---so list order is important
    ---@type string[]
    include = {
        user_templates,
        builtin_templates,
    },
    ---A table with patterns and template file names.
    ---Patterns should be file names containing wildcards
    ---e. g. `*.lua` or `ftplugin/*.vim`.
    ---skel.lua is not defined since auto_skelettons defaults to true.
    ---Paths can be absolute, in this case the include folders will not
    ---be searched.
    ---@type table<string,string|Modneo.Templates.Config.TemplateEntry>
    templates = {
        ["ftplugin/*.vim"] = "ftplugin.vim",
    },
    ---can be set to true to prevent automatic template loading for new files.
    ---Defaults to false since this is the primary use case for this plugin.
    ---@type boolean
    no_autoload = false,
    ---rutomatically adds files named `skel.*` found in template directories
    ---as template for *.ext where _ext_ is the suffix of the _skel_ file.
    ---Default is true.
    ---@type boolean
    auto_skeletons = true,
}

---normalizes the template paths in passed options
---@param options Modneo.Templates.ConfigOptions
---@return Modneo.Templates.ConfigOptions
local function normalize_includes(options)
    for i, dir in ipairs(options.include or {}) do
        if dir == false then
            goto continue
        end
        if vim.fs.abspath(dir) ~= dir then
            options.include[i] = vim.fs.joinpath(vim.fn.stdpath("config"), dir)
        end
        ::continue::
    end
    return options
end

---adds skeletton files found in dir to templates with fitting patterns
---@param dir string
---@param options Modneo.Templates.ConfigOptions
local function add_skelettons_from_dir(dir, options)
    local fileexp = vim.fs.joinpath(dir, "skel.*")
    local skelettons = vim.fn.glob(fileexp, false, true, false)
    for _, file in ipairs(skelettons) do
        local tpl_name = vim.fs.basename(file)
        local pattern = "*" .. tpl_name:match("%..*")
        if options.templates[pattern] == nil then
            options.templates[pattern] = tpl_name
        end
    end
end

---normalizes the template entries in place
---@param options Modneo.Templates.ConfigOptions
local function normalize_templates(options)
    local factory = require('modneo-templates.config.template_entry')
    for pat, tpl in pairs(options.templates) do
        options.templates[pat] = factory.new(tpl)
    end
end

---@class Modneo.Templates.Config
---@field options Modneo.Templates.ConfigOptions
local M = {}

---adds skeletton files `skel.*` to the template list missing
---in current templates mapping property. The extension will be taken from
---the skeletton file.
---
---Templates will be added as simple file names.
---This also avoids duplicate adding of files found in more than one directory.
M.add_skeletons = function()
    if M.options == nil then
        error("cannot be called before init or setup")
    end
    for _, dir in ipairs(M.options.include) do
        add_skelettons_from_dir(dir, M.options)
    end
    vim.g.modneo_templates_auto_skel_loaded = 1
end

---initializes the plugin with default settings
---@type function
---@return Modneo.Templates.ConfigOptions
M.init = function()
    return M.setup({})
end

---initializes or resets the plugin with user options
---@param opts Modneo.Templates.ConfigOptions? user defined options
---@return Modneo.Templates.ConfigOptions
M.setup = function(opts)
    opts = normalize_includes(opts or {})
    M.options = vim.tbl_deep_extend("force", M.options or {}, defaults, opts)
    -- remove defaults if user templates are set manually or false is included
    if
        opts.include ~= nil
        and (
            vim.tbl_contains(opts.include, user_templates)
            or vim.tbl_contains(opts.include, false)
        )
    then
        M.options.include = vim.tbl_filter(function(v)
            return type(v) == "string"
        end, opts.include)
    end
    -- reset templates with settings if builtin templates are not included
    if opts.templates ~= nil and not vim.tbl_contains(M.options.include, builtin_templates) then
        M.options.templates = opts.templates
        vim.g.modneo_templates_auto_skel_loaded = 0
    end
    if M.options.auto_skeletons and vim.g.modneo_templates_auto_skel_loaded ~= 1 then
        M.add_skeletons()
    end
    normalize_templates(M.options)
    M.options.templates_iter = function()
        return pairs(M.options.templates)
    end
    return M.options
end

return M
