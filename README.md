# tiny.nvim templates support

Tiny module to support template usage

## Setup 🚀and Configuration ⚙ 

Setup with Lazy

```lua
return {
    "Coding4Glory/tiny-templates.nvim",
    -- default options, pass an empty table to use defaults
    opts = {
        include = {
            vim.fs.joinpath(vim.fn.stdpath('config'), 'templates'),
            vim.fs.joinpath(vim.fn.stdpath('data'), 'lazy', 'tiny-templates.nvim', 'templates')
        },
        templates = {
            ['*.lua'] = 'skel.lua',
            ['ftplugin/*.vim'] = 'ftplugin.vim',
        }
    }
}
```

## Usage 🛠

Place your templates into the template directory, default on linux is `~/.config/nvim/templates`.

Other OS place accordingly to `vim.fs.joinpath(vim.fn.stdpath('config'), 'templates')`

