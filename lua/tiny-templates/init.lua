---loads the template according
---@param include_paths string[] the paths to search for templates in order
---@param template string the template name to apply
local function load_template(include_paths, template)
     for _, p in ipairs(include_paths) do
        local template_path = vim.fs.joinpath(p, template)
        if vim.uv.fs_stat(template_path) then
            vim.cmd('0read' .. template_path)
            return
        end
    end
end

---@class TinyTemplates
return {
    ---@type function 
    ---initializes the module by setting up auto commands for configured file patterns
    ---@param opts TemplateSettings
    setup = function(opts)
        local config = require('tiny-templates.config').setup(opts)
        local template_group = vim.api.nvim_create_augroup('tiny_templates', { clear = true, })
        for p, t in pairs(config.templates) do
            vim.api.nvim_create_autocmd({ 'BufNewFile' },
                {
                    pattern = p,
                    group = template_group,
                    callback = load_template(config.include, t)
                })
        end
    end
}

