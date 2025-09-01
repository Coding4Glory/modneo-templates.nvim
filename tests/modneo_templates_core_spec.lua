local empty_count = 1
local defaults = require('modneo-templates.config').init()
local fixture_path = vim.fs.joinpath((vim.uv or vim.loop).cwd(), "tests", "fixture")
require("plenary.busted")

describe("fixture/skel.txt only", function()
    require("modneo-templates").setup({
        include = {
            false, -- remove default paths to avoid interference from installed plugin
            fixture_path,
        },
        templates = { ['*.txt'] = 'skel.txt' },
        auto_skeletons = false
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
    require("modneo-templates").setup({
        include = {
            false,
            fixture_path,
            vim.fs.joinpath((vim.uv or vim.loop).cwd(), "templates"),
        },
        templates = defaults.templates,
    })

    it("creates a new buffer initialized with ftplugin template", function()
        local filename = "ftplugin/test.vim"
        vim.cmd("edit " .. filename)
        local buf = vim.fn.bufadd(filename)
        assert(vim.api.nvim_buf_line_count(buf) > empty_count, "there are no lines!")
        vim.cmd("bw! " .. buf)
    end)
end)

describe("replace block after skeletton", function()
    require("modneo-templates").setup({
        include = { false, fixture_path },
        templates = {
            ["*.txt"] = { "with_replace.txt", replace = { ["{{ TO REPLACE }}"] = "skel.txt" } },
        },
    })
    it("uses a template with file replacement", function()
        local compare_file = vim.fs.joinpath((vim.uv or vim.loop).cwd(), "tests", "fixture", "with_replace.txt")
        vim.cmd("edit " .. compare_file)
        local compare_count = vim.api.nvim_buf_line_count(vim.fn.bufnr(compare_file))
        assert(compare_count > empty_count, "Compare file not properly loaded")
        vim.api.nvim_buf_delete(vim.fn.bufnr(compare_file), { force = true })

        local filename = "test.txt"
        vim.cmd("edit " .. filename)
        local buf = vim.fn.bufadd(filename)
        -- for some reason an empty line is added in the end
        assert(vim.api.nvim_buf_line_count(buf) - 1 > compare_count, "Replacement not performed")
    end)
end)
