# modneo-templates

Neovim plugin for simple file template usage

## Setup 🚀and Configuration ⚙ 

Setup with Lazy

```lua
return {
    -- repo will be renamed according to new project name soon!
    "Coding4Glory/tiny-templates.nvim",
    -- default options, pass an empty table to use defaults
    opts = {
        include = {
            vim.fs.joinpath(vim.fn.stdpath('config'), 'templates'),
            vim.fs.joinpath(vim.fn.stdpath('data'), 'lazy', 'modneo-templates.nvim', 'templates')
        },
        templates = {
            ['*.lua'] = 'skel.lua',
            ['ftplugin/*.vim'] = 'ftplugin.vim',
        },
        no_autoload = false
    }
}
```

## Usage 🛠

### Template Files

If not changed via options place your templates into the template directory, default on linux is `~/.config/nvim/templates`. Other OS place accordingly to `vim.fs.joinpath(vim.fn.stdpath('config'), 'templates')`. The order of directories specified in the include option is important. Only the first found template will be loaded. This way multiple folders can be used for fallback or override. The plugin contains two example templates.

- ftplugin.vim: a template for filetype plugins
- skel.lua: a template for lua modules

### Commands ⌨

```vimdoc
                                                                *TemplateApply*
:TemplateApply[!] {arg}      Fills the buffer with the template. If the buffer
                             already contains more than one line, the command
                             will do nothing. Use bang to clear the file in
                             advance which will override the buffer with the
                             template content. WARNING if the template is not
                             found, the buffer will still be cleared.

                                                                  *TemplateAdd*
:TemplateAdd {arg}           Adds the contents of the template at the cursor
                             line.

Both commands require the same argument with is either the pattern used to
match the new file or the simple file name of the template, examples based on
default configuration:

    :TemplateApply! ftplugin.vim
    :TemplateAdd *.lua
```
