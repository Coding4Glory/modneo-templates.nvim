local empty_count = 1
local defaults = require('modneo-templates.config').init()
require('plenary.busted')

describe("fixture/skel.txt only", function()
    require("modneo-templates").setup({
        include = {
            false, -- remove default paths to avoid interference from installed plugin
            vim.fs.joinpath((vim.uv or vim.loop).cwd(), "tests", "fixture")
        },
        templates = { ['*.txt'] = 'skel.txt' },
        auto_skelettons = false
    })

    it("creates an empty buffer", function()
        local filename = "test.lua"
        vim.cmd("edit " .. filename)
        local buf = vim.fn.bufadd(filename)
        assert(vim.api.nvim_buf_line_count(buf) <= empty_count, "buffer should be empty")
        vim.cmd("bw! " .. buf)
    end)
    it("creates a new buffer initialized with a template", function()
        local filename = "test.txt"
        vim.cmd("edit " .. filename)
        local buf = vim.fn.bufadd(filename)
        assert(vim.api.nvim_buf_line_count(buf) > empty_count, "there are no lines!")
        vim.cmd("bw! " .. buf)
    end)
end)

describe("mimic default settings", function()
    require('modneo-templates').setup({
        include = {
            false,
            vim.fs.joinpath((vim.uv or vim.loop).cwd(), "tests", "fixture"),
            vim.fs.joinpath((vim.uv or vim.loop).cwd(), "templates")
        },
        templates = defaults.templates
    })

    it("creates a new buffer initialized with ftplugin template", function()
        local filename = "ftplugin/test.vim"
        vim.cmd("edit " .. filename)
        local buf = vim.fn.bufadd(filename)
        assert(vim.api.nvim_buf_line_count(buf) > empty_count, "there are no lines!")
        vim.cmd("bw! " .. buf)
    end)
end)
