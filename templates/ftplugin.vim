" Copyright (c) 2025 Markus Hergenröder
" 
" May be used, modified and redistributed without any restrictions implied by GPL-3.0+
" This includes the above copyright notice.
"
" ftplugin/ files are sourced by the filetype plugin itself and need to be
" written in vim script. Replace the <filetype> place holder with a file type
" not already coverd by a different ftplugin script
"
" ensure script runs only once per buffer but allow file type changes
if exists("b:tiny_ftplugin") && b:tiny_ftplugin == "<filetype>"
  finish
endif
let b:tiny_ftplugin = "<filetype>"

setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=4
"setlocal textwidth=80
setlocal expandtab
setlocal smarttab
"setlocal autoindent
"setlocal smartindent
"setlocal cindent
"setlocal number

" ensure all ftplugins use the same augroup so they get cleared properly if
" the filetype was changed
augroup tiny_ftplugin
  aucmd!
  " define custom keybindings in this section, you may use <localleader>
  " instead of <leader> to avoid confision with global mappings e. g. 
  " `nmap <localleader>bd <Cmd>BuildDocs<CR>`
augroup END


