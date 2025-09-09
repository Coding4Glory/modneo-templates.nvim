local empty_count = 1
local defaults = require('modneo-templates.config').init()
local fixture_path = vim.fs.joinpath((vim.uv or vim.loop).cwd(), 'tests', 'fixture')
require('plenary.busted')

describe('fixture/skel.txt only', function()
    require('modneo-templates').setup({
        include = {
            false, -- remove default paths to avoid interference from installed plugin
            fixture_path,
        },
        templates = { ['*.txt'] = 'skel.txt' },
        auto_skeletons = false
    })

    it('creates an empty buffer', function()
        local filename = 'test.lua'
        vim.cmd('edit ' .. filename)
        local buf = vim.fn.bufadd(filename)
        assert(vim.api.nvim_buf_line_count(buf) <= empty_count, 'buffer should be empty')
        vim.cmd('bw! ' .. buf)
    end)
    it('creates a new buffer initialized with a template', function()
        local filename = 'test.txt'
        vim.cmd('edit ' .. filename)
        local buf = vim.fn.bufadd(filename)
        assert(vim.api.nvim_buf_line_count(buf) > empty_count, 'there are no lines!')
        vim.cmd('bw! ' .. buf)
    end)
end)

describe('mimic default settings', function()
    require('modneo-templates').setup({
        include = {
            false,
            fixture_path,
            vim.fs.joinpath((vim.uv or vim.loop).cwd(), 'templates'),
        },
        templates = defaults.templates,
    })

    it('creates a new buffer initialized with ftplugin template', function()
        local filename = 'ftplugin/test.vim'
        vim.cmd('edit ' .. filename)
        local buf = vim.fn.bufadd(filename)
        assert(vim.api.nvim_buf_line_count(buf) > empty_count, 'there are no lines!')
        vim.cmd('bw! ' .. buf)
    end)
end)

describe('replacement after skeletton', function()
    it('using file', function()
        require('modneo-templates').setup({
            include = { false, fixture_path },
            templates = {
                ['*.txt'] = {
                    'with_replace.txt',
                    replace = { '{{ TO REPLACE }}', 'skel.txt' },
                },
            },
        })
        local compare_file = vim.fs.joinpath(
            (vim.uv or vim.loop).cwd(),
            'tests',
            'fixture',
            'with_replace.txt'
        )
        vim.cmd('edit ' .. compare_file)
        local compare_count = vim.api.nvim_buf_line_count(vim.fn.bufnr(compare_file))
        assert(compare_count > empty_count, 'Compare file not properly loaded')
        vim.api.nvim_buf_delete(vim.fn.bufnr(compare_file), { force = true })

        local filename = 'test.txt'
        vim.cmd('edit ' .. filename)
        local buf = vim.fn.bufadd(filename)
        -- for some reason an empty line is added in the end
        assert(
            vim.api.nvim_buf_line_count(buf) - 1 > compare_count,
            'Replacement not performed'
        )
        assert.equal(0, #vim.fn.matchbufline(buf, '{{ TO REPLACE }}', 1, '$'))
        vim.cmd('bd!')
    end)

    it('using string', function()
        require('modneo-templates').setup({
            include = { false, fixture_path },
            templates = {
                ['*.txt'] = {
                    'with_replace.txt',
                    replace = { '{{ TO REPLACE }}', 'The new value' },
                },
            },
        })
        local compare_file = vim.fs.joinpath(
            (vim.uv or vim.loop).cwd(),
            'tests',
            'fixture',
            'with_replace.txt'
        )
        vim.cmd('edit ' .. compare_file)
        local compare_count = vim.api.nvim_buf_line_count(vim.fn.bufnr(compare_file))
        assert(compare_count > empty_count, 'Compare file not properly loaded')
        vim.api.nvim_buf_delete(vim.fn.bufnr(compare_file), { force = true })
        local filename = 'test.txt'
        vim.cmd('edit ' .. filename)
        local buf = vim.fn.bufadd(filename)
        assert.not_equal(0, #vim.fn.matchbufline(buf, 'The new value', 1, '$'))
        assert.not_equal(0, #vim.fn.matchbufline(buf, 'To stay', 1, '$'))
        vim.cmd('bd!')
    end)
    it('using multi line string', function()
        require('modneo-templates').setup({
            include = { false, fixture_path },
            templates = {
                ['*.txt'] = {
                    'with_replace.txt',
                    replace = {
                        '{{ TO REPLACE }}',
                        { 'The new value', '', 'and another line' },
                        'multiline',
                    },
                },
            },
        })
        local compare_file = vim.fs.joinpath(
            (vim.uv or vim.loop).cwd(),
            'tests',
            'fixture',
            'with_replace.txt'
        )
        vim.cmd('edit ' .. compare_file)
        local compare_count = vim.api.nvim_buf_line_count(vim.fn.bufnr(compare_file))
        assert(compare_count > empty_count, 'Compare file not properly loaded')
        vim.api.nvim_buf_delete(vim.fn.bufnr(compare_file), { force = true })
        local filename = 'test.txt'
        vim.cmd('edit ' .. filename)
        local buf = vim.fn.bufadd(filename)
        assert.not_equal(0, #vim.fn.matchbufline(buf, 'The new value', 1, '$'))
        vim.cmd('bd!')
    end)

    describe('using system command', function()
        it('returning single line', function()
            require('modneo-templates').setup({
                include = { false, fixture_path },
                templates = {
                    ['*.txt'] = {
                        'with_replace.txt',
                        replace = {
                            '{{ TO REPLACE }}',
                            { 'echo', 'The', 'new', 'value' },
                        },
                    },
                },
            })
            local compare_file = vim.fs.joinpath(
                (vim.uv or vim.loop).cwd(),
                'tests',
                'fixture',
                'with_replace.txt'
            )
            vim.cmd('edit ' .. compare_file)
            local compare_count = vim.api.nvim_buf_line_count(vim.fn.bufnr(compare_file))
            assert(compare_count > empty_count, 'Compare file not properly loaded')
            vim.api.nvim_buf_delete(vim.fn.bufnr(compare_file), { force = true })
            local filename = 'test.txt'
            vim.cmd('edit ' .. filename)
            local buf = vim.fn.bufadd(filename)
            assert.not_equal(0, #vim.fn.matchbufline(buf, 'The new value', 1, '$'))
            assert.not_equal(0, #vim.fn.matchbufline(buf, 'To stay', 1, '$'))
            assert.equal(0, #vim.fn.matchbufline(buf, '{{ TO REPLACE }}', 1, '$'))
            vim.cmd('bd!')
        end)
        it('returning multi line', function()
            require('modneo-templates').setup({
                include = { false, fixture_path },
                templates = {
                    ['*.txt'] = {
                        'with_replace.txt',
                        replace = {
                            '{{ TO REPLACE }}',
                            {
                                'echo',
                                '-e',
                                'The',
                                'new',
                                'value',
                                '\\n',
                                'some',
                                'other',
                                'line',
                            },
                        },
                    },
                },
            })
            local compare_file = vim.fs.joinpath(
                (vim.uv or vim.loop).cwd(),
                'tests',
                'fixture',
                'with_replace.txt'
            )
            vim.cmd('edit ' .. compare_file)
            local compare_count = vim.api.nvim_buf_line_count(vim.fn.bufnr(compare_file))
            assert(compare_count > empty_count, 'Compare file not properly loaded')
            vim.api.nvim_buf_delete(vim.fn.bufnr(compare_file), { force = true })
            local filename = 'test.txt'
            vim.cmd('edit ' .. filename)
            local buf = vim.fn.bufadd(filename)
            assert.not_equal(0, #vim.fn.matchbufline(buf, 'The new value', 1, '$'))
            assert.equal(0, #vim.fn.matchbufline(buf, '{{ TO REPLACE }}', 1, '$'))
            vim.cmd('bd!')
        end)
    end)
    describe('using callback', function()
        it('with no result', function()
            require('modneo-templates').setup({
                include = { false, fixture_path },
                templates = {
                    ['*.txt'] = {
                        'with_replace.txt',
                        replace = {
                            '{{ TO REPLACE }}',
                            function(ctx)
                                vim.cmd(
                                    '%s/'
                                    .. ctx.pattern
                                    .. '/this is a test, you should not do this unless you exactly now your pattern does not interfere/g'
                                )
                            end,
                        },
                    },
                },
            })
            local filename = 'test.txt'
            vim.cmd('edit ' .. filename)
            local buf = vim.fn.bufadd(filename)
            assert.not_equal(0, #vim.fn.matchbufline(buf, 'this is a test', 1, '$'))
            assert.equal(0, #vim.fn.matchbufline(buf, '{{ TO REPLACE }}', 1, '$'))
            vim.cmd('bd!')
        end)
        it('with single line result', function()
            require('modneo-templates').setup({
                include = { false, fixture_path },
                templates = {
                    ['*.txt'] = {
                        'with_replace.txt',
                        replace = {
                            '{{ TO REPLACE }}',
                            function(ctx)
                                assert.is_equal('{{ TO REPLACE }}', ctx.pattern)
                                assert.are_match('with_replace.txt', ctx.template)
                                return '/this is a test'
                            end,
                        },
                    },
                },
            })
            local filename = 'test.txt'
            vim.cmd('edit ' .. filename)
            local buf = vim.fn.bufadd(filename)
            assert.not_equal(0, #vim.fn.matchbufline(buf, '/this is a test', 1, '$'))
            assert.equal(0, #vim.fn.matchbufline(buf, '{{ TO REPLACE }}', 1, '$'))
            vim.cmd('bd!')
        end)
        it('with multi line result', function()
            require('modneo-templates').setup({
                include = { false, fixture_path },
                templates = {
                    ['*.txt'] = {
                        'with_replace.txt',
                        replace = {
                            '{{ TO REPLACE }}',
                            function(_)
                                return { 'this is a test', '', 'from function' }
                            end,
                        },
                    },
                },
            })
            local filename = 'test.txt'
            vim.cmd('edit ' .. filename)
            local buf = vim.fn.bufadd(filename)
            assert.not_equal(0, #vim.fn.matchbufline(buf, 'this is a test', 1, '$'))
            assert.not_equal(0, #vim.fn.matchbufline(buf, 'from function', 1, '$'))
            assert.equal(0, #vim.fn.matchbufline(buf, '{{ TO REPLACE }}', 1, '$'))
            vim.cmd('bd!')
        end)
    end)
end)
