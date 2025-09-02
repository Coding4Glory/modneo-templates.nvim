require('plenary.busted')

describe('initialize with defaults:', function()
    it ('has options set', function()
        local options = require('modneo-templates.config').init()
        -- assert.is_nil(config)
        assert.not_nil(options)
        assert.not_nil(options.templates)
        assert.not_nil(options.include)
        assert.is_true(options.auto_skeletons)
        assert.not_nil(options.templates['*.lua'])
    end)
end)

describe('setup with custom:', function()
    local default_paths = require('modneo-templates.config').init().include
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
        })
        assert.is_true(options.auto_skeletons)
        assert.is_equal(1, vim.g.modneo_templates_auto_skel_loaded)
        assert.is_nil(options.templates['ftplugin/*.vim'])
        assert.is_equal('skel.lua', options.templates['*.lua'])
    end)
end)
