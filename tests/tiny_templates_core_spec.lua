local empty_count = 1
require('plenary.busted')

describe("tests for tiny-templates.nvim core", function()
    describe("with default config", function()
        require("tiny-templates").setup()
        it("creates a new buffer initialized with a template", function()
            local filename = "test.lua"
            vim.cmd("edit " .. filename)
            local buf = vim.fn.bufadd(filename)
            assert(vim.api.nvim_buf_line_count(buf) > empty_count, "there are no lines!")
            vim.cmd("bw! " .. buf)
        end)
        it("creates an empty buffer", function()
            local filename = "test.txt"
            vim.cmd("edit " .. filename)
            local buf = vim.fn.bufadd(filename)
            assert(vim.api.nvim_buf_line_count(buf) <= empty_count, "buffer should be empty")
            vim.cmd("bw! " .. buf)
        end)
    end)

    describe("with custom config", function()
        require("tiny-templates").setup({
            include = { vim.fs.joinpath((vim.uv or vim.loop).cwd(), "tests", "fixture") },
            templates = {
                ["*.txt"] = "skel.txt",
            },
        })

        it("creates an empty buffer", function()
            local filename = "ftplugin/test.vim"
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
end)
