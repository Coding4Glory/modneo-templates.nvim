# modneo-templates

Neovim plugin for simple file template usage

## Setup 🚀and Configuration ⚙

Setup with Lazy

```lua
return {
    -- repo will be renamed according to new project name soon!
    "Coding4Glory/modneo-templates.nvim",
    -- default options, pass an empty table to use defaults
    opts = {
        ---a list of paths to search for templates, first template found will be used
        ---so list order is important
        include = {
            vim.fs.joinpath(vim.fn.stdpath('config'), 'templates'),
            vim.fs.joinpath(vim.fn.stdpath('data'), 'lazy', 'modneo-templates.nvim', 'templates')
        },
        ---A table with patterns and template file names.
        ---Patterns should be file names containing wildcards
        ---e. g. `*.lua` or `ftplugin/*.vim`.
        ---skel.lua is not defined since auto_skelettons defaults to true.
        ---Paths can be absolute, in this case the include folders will not
        ---be searched.
        templates = {
            ['ftplugin/*.vim'] = 'ftplugin.vim',
        },
        ---can be set to true to prevent automatic template loading for new files.
        ---Defaults to false since this is the primary use case for this plugin.
        no_autoload = false,
        ---rutomatically adds files named `skel.*` found in template directories
        ---as template for *.ext where _ext_ is the suffix of the _skel_ file.
        ---Defaults to false to avoid adding during init.
        ---The plugin comes with a skel.lua template which is detected this way.
        auto_skeletons = true,
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

<!-- vim: set et ts=4 sw=4 tw=0: -->
