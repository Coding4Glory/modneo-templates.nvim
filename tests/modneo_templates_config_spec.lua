describe('initialize with defaults:', function()
    it ('has options set', function()
        local config = require('modneo-templates.config').init()
        assert.not_nil(config.options)
        assert.not_nil(config.options.templates)
        assert.not_nil(config.options.include)
        assert.is_false(config.options.auto_skelettons)
    end)
end)

describe('setup with custom:', function()
    local default_paths = require('modneo-templates.config').init().options.include
    local fixture_path = vim.fs.joinpath((vim.uv or vim.loop).cwd(), "tests", "fixture")
    it ('paths are normalized', function()
        local options = require('modneo-templates.config').setup({
            include = {
                false,
                fixture_path,
                'tmp/nothere'
            }
        })
        for _, p in ipairs(options.include) do
            assert.is_equal(p, vim.fs.abspath(p))
        end
    end)

    it ('no default paths', function()
        local options = require('modneo-templates.config').setup({
            include = {
                false,
                fixture_path
            }
        })

        assert.is_false(vim.tbl_contains(options.include, false), "reset value not removed")
        for _, p in ipairs(default_paths) do
            assert.is_false(vim.tbl_contains(options.include, p), "default path still present")
        end

    end)
    it ('auto skelettons only', function()
        local options = require('modneo-templates.config').setup({
            include = {
                false,
                fixture_path
            },
            templates = {},
            auto_skelettons = true,
        })
        assert.is_true(options.auto_skelettons)
        assert.is_equal(1, vim.g.modneo_templates_auto_skel_loaded)
        assert.is_nil(options.templates['ftplugin/*.vim'])
        assert.is_equal('skel.lua', options.templates['*.lua'])
    end)
end)
