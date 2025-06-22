return {
    setup = function(opts)
        local config = require('tiny-templates.config').setup(opts)
        local template_group = vim.api.nvim_create_augroup('tiny_templates', { clear = true, })
        for p, t in pairs(config.templates) do
            vim.api.nvim_create_autocmd({ 'BufNewFile' },
                {
                    pattern = p,
                    group = template_group,
                    callback = function()
                        for _, f in ipairs(config.include) do
                            local template_path = vim.fs.joinpath(f, t)
                            if vim.uv.fs_stat(template_path) then
                                vim.cmd('0read' .. template_path)
                                return
                            end
                        end
                    end
                })
        end
    end
}

