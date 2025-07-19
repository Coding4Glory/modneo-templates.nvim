local function ensure_plenary(fallback)
        local locations = {
        -- lazy path
        vim.fs.joinpath(vim.fn.stdpath('data'), 'lazy', 'plenary.nvim'),
        -- direct path
        vim.fs.joinpath(vim.fn.stdpath('data'), 'plenary.nvim'),
        -- last item will be created
        fallback,
    }

    for _, p in ipairs(locations) do
        if vim.fn.isdirectory(p) then
            return p
        end
    end
    -- plenary not found
    vim.fn.system({ 'git', 'clone', 'https://github.com/nvim-lua/plenary.nvim', fallback })
    return fallback
end

local plenary_path = ensure_plenary(os.getenv('PLENARY_DIR') or '/tmp/plenary.nvim')
vim.opt.rtp:append(plenary_path)
vim.opt.rtp:append('.')

vim.cmd('runtime plugin/plenary.vim')

