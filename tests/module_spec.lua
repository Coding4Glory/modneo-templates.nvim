require("tiny-templates").setup()

describe("tests for tiny-templates.nvim", function()
	it("creates a new buffer initialized with a template", function()
        local filename = "test.lua"
		vim.cmd("edit " .. filename)
		local buf = vim.fn.bufadd(filename)
		assert(vim.api.nvim_buf_line_count(buf) > 0, "there are no lines!")
        vim.cmd("bw!" .. buf)
	end)
	it("creates an empty buffer", function()
	    local filename = "test.txt"
		vim.cmd("edit " .. filename)
		local buf = vim.fn.bufadd(filename)
		assert(vim.api.nvim_buf_line_count(buf) <= 1, "buffer should be empty")
        vim.cmd("bw!" .. buf)
	end)
	it("adds a template", function()
	    local filename = "add.txt"
		vim.cmd("edit " .. filename)
		local buf = vim.fn.bufadd(filename)
		assert(vim.api.nvim_buf_line_count(buf) <= 1, "buffer should be empty")

		vim.cmd("TemplateAdd ftplugin.lua")
		assert(vim.api.nvim_buf_line_count(buf) > 0, "there are no lines!")
        vim.cmd("bw!" .. buf)
	end)
	it("applies a template", function()
	    local filename = "apply.lua"
		vim.cmd("edit " .. filename)
		local buf = vim.fn.bufadd(filename)
		local line_count = vim.api.nvim_buf_line_count(buf)

		vim.cmd("TemplateApply! ftplugin.vim")
		assert(vim.api.nvim_buf_line_count(buf) > line_count, "content has not changed")
        vim.cmd("bw!" .. buf)
	end)
	it("does not apply a template", function()
	    local filename = "dontapply.lua"
		vim.cmd("edit " .. filename)
		local buf = vim.fn.bufadd(filename)
		local line_count = vim.api.nvim_buf_line_count(buf)

		vim.cmd("TemplateApply ftplugin.vim")
		assert(vim.api.nvim_buf_line_count(buf) == line_count, "content has changed")
        vim.cmd("bw!" .. buf)
	end)
end)
