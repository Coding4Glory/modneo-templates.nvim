# modneo-templates

Neovim plugin for file template usage with some advanced features. But you can also use it instead of a vimscript like the following:

```vimscript
augroup my_templates
    autocmd!
    au BufNewFile *.lua 0read ~/.config/nvim/templates/skel.lua
    au BufNewFile ftplugin/.vim 0read ~/.config/nvim/templates/ftplugin.skel
augroup END
```

You might setup something similar already or not. Here is how it works.

## Setup 🚀

Setup with Lazy simply add the git slug to your configuration.

```lua
require('lazy').setup({
    spec = {
        -- what ever you've already here
        { "Coding4Glory/modneo-templates.nvim" },
    }
})
```

The plugin provides an init function therefor no explicit options are required. Following example shows the default options and what they mean.

```lua
{
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
        ---Set to false to avoid detection during init.
        ---The plugin comes with a skel.lua template which is detected this way.
        auto_skeletons = true,
    }
}
```

## Configuration ⚙ and Usage 🛠

### Replacements

The plugin also supports pattern replacement in files. This can be archieved by a sligthly more complex configuration. For the `templates` option. If code completion and lsp are enabled for your configuration you should see a brief description while typing. A file can have one or multiple replacements. If only one is required or desired a single rule is enough. Simple file names and configurations with replacements can be mixed. So both forms are supported:

```
-- one rule
repalce = { ... }
-- or multiple rules
replace = { {...}, ... }
```

The full form of a rule is `{ 'pattern', <action>, [ 'type' ] }`, where type is optional and usually not required but automatically detected by the given action. You can simple remember it as _{ 'lhs', rhs }_ where lhs is always a pattern.

> Forward slashes `/` in *pattern* will be automatically escaped if required. Don't escaping them on your own except it's a workaround for an unfixed bug.

The Action can be:

- a simple string, usage evaluated as following:
    1. when starting with a colon, it will be interpreted as command. The result (return value) is used for replacement.
    1. normally as file name, except if file cannot be found.
    1. string itself will be used.
- a simple lua list (string[]): will be interpreted as system command.
- a function, will be called with pattern and the **initially** loaded template.


Via the _type_ it's possible to provide a hint if the a value is miss interpreted or shall be overriden. Following types are supported.

| type | compatible with | enforces |
| file | string | usage of file, no replacement will happen if file is not found |
| string | string | the string will be used as static replacement |
| command | string | the string will be interpreted as command |
| system | array | the string will be treated as system command |
| callback | function | only defined because used internally |
| multiline | array | only defined because required internally and might be removed |

**Simple replacement**

```lua
opts = {
    templates = {
        ['*.c'] = {
            'skel.c',
                -- simply replace a text
            replace = { '{{ AUTHOR }}', 'John Doe' }
        }
    }
}
```

**Two replacements**

```lua
opts = {
    templates = {
        ['*.c'] = {
            'skel.c',
            replace = {
                -- assuming there is a file GPLv3.short in a license folder which can be found in a include directory
                -- e. g. ~/.config/nvim/templates/licenses/MyLicense.short
                { '{{ LICENSE }}', 'licenses/MyLicense.short' },
                -- to add the year if the MyLicense.short file contains the <YEAR> string
                { '<YEAR>', { 'date', '+"%Y"' } }
            }
        }
    }
}
```

**Using a function**

```lua
opts = {
    templates
}
```

****

##

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

### Usage within scripts

When utilizting the plugin inside code you might consider using the public api of the core class. The plugin is already meant to be set up.

```
-- if not allready done, initialize module
require('modeno-templates').setup({})

local templates = require'modneo-templates.core'

-- to load plugin
local filename = 'my-file.txt' -- inside include directory
templates.load_at(filename) -- to preprend template to first line
templates.load_at(filename, 5) -- to load at line nr 5

-- replace pattern with file
local rule = { '{ contents of my/template.txt', 'template.txt' }
templates.replace(rule)
```

Remember you can always load a file with the `read` command.


## Contribution

<!-- vim: set et ts=4 sw=4 tw=0: -->
