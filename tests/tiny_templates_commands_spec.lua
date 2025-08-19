describe("tests for tiny-templates.nvim commands", function()
    describe("with default config", function()
        require("tiny-templates").setup()
        it("checks for default options", function()
            local options = require("tiny-templates.config").options
            assert.is_equal(2, table.maxn(options.include))
            assert.is_truthy((vim.uv or vim.loop).fs_stat(options.include[1]))
        end)

        it("adds a template", function()
            local filename = "add.txt"
            vim.cmd("edit " .. filename)
            local buf = vim.fn.bufadd(filename)
            local line_count = vim.api.nvim_buf_line_count(buf)

            vim.cmd("TemplateAdd ftplugin.vim")
            assert.not_equal(line_count, vim.api.nvim_buf_line_count(buf))
            vim.cmd("bw! " .. buf)
        end)
        it("applies a template", function()
            local filename = "apply.lua"
            vim.cmd("edit " .. filename)
            local buf = vim.fn.bufadd(filename)
            local line_count = vim.api.nvim_buf_line_count(buf)

            vim.cmd("TemplateApply! ftplugin.vim")
            assert.not_equal(line_count, vim.api.nvim_buf_line_count(buf))
            vim.cmd("bw! " .. buf)
        end)
        it("does not apply a template", function()
            local filename = "dontapply.lua"
            vim.cmd("edit " .. filename)
            local buf = vim.fn.bufadd(filename)
            local line_count = vim.api.nvim_buf_line_count(buf)

            vim.cmd("TemplateApply ftplugin.vim")
            assert.is_equal(line_count, vim.api.nvim_buf_line_count(buf))
            vim.cmd("bw! " .. buf)
        end)
    end)

    describe("with custom config", function()
        require("tiny-templates").setup({
            include = { vim.fs.joinpath((vim.uv or vim.loop).cwd(), "tests", "fixture") },
            templates = {
                ["*.txt"] = "skel.txt",
                ["*.lua"] = "skel.lua",
            },
        })

        it("adds fixture template", function()
            local filename = "add2.lua"
            vim.cmd("edit " .. filename)
            local buf = vim.fn.bufadd(filename)
            local line_count = vim.api.nvim_buf_line_count(buf)
            vim.cmd("TemplateAdd *.txt")
            assert.not_equal(line_count, vim.api.nvim_buf_line_count(buf))
            vim.cmd("bw! " .. buf)
        end)
        it("applies fixture template", function()
            local filename = "apply2.txt"
            vim.cmd("edit " .. filename)
            local buf = vim.fn.bufadd(filename)
            local line_count = vim.api.nvim_buf_line_count(buf)

            vim.cmd("TemplateApply! skel.lua")
            assert.not_equal(line_count, vim.api.nvim_buf_line_count(buf))
            vim.cmd("bw! " .. buf)
        end)
        it("does not apply a template", function()
            local filename = "dontapply2.lua"
            vim.cmd("edit " .. filename)
            local buf = vim.fn.bufadd(filename)
            local line_count = vim.api.nvim_buf_line_count(buf)

            vim.cmd("TemplateApply skel.txt")
            assert.is_equal(line_count, vim.api.nvim_buf_line_count(buf))
            vim.cmd("bw! " .. buf)
        end)
        it("does not find a template", function()
            local filename = "notfound2.vim"
            vim.cmd("edit " .. filename)
            local buf = vim.fn.bufadd(filename)
            local line_count = vim.api.nvim_buf_line_count(buf)

            vim.cmd("TemplateApply! ftplugin.vim")
            assert.is_equal(line_count, vim.api.nvim_buf_line_count(buf))
            vim.cmd("bw! " .. buf)
        end)    end)
end)
