" vim: set fdm=marker et ts=4 sw=4 sts=4:
" listmode.vim - Vim: List mode for pandoc version of markdown
" Author:        bwhelm
" Version:       0.1

if exists('g:ListMode_loaded') || &cp
    finish
endif

let g:ListMode_loaded = 1


" Define commands
command! ListModeToggle call listmode#ToggleListMode()

" Default keymappings {{{1

if !exists('g:vim_listmode_map_prefix')
	let g:vim_listmode_map_prefix = '<leader>'
endif

if !exists('g:vim_listmode_toggle')
    let g:vim_listmode_toggle = g:vim_listmode_map_prefix."lm"
endif

if !exists('g:vim_listmode_reformat')
    let g:vim_listmode_reformat = g:vim_listmode_map_prefix."lr"
endif

execute "noremap" g:vim_listmode_toggle ":ListModeToggle<CR>"
execute "noremap" g:vim_listmode_reformat ":call ReformatList()<CR>"

if !exists('g:ListMode_indent_normal')
    let g:ListMode_indent_normal = "<Tab>"
endif

if !exists('g:ListMode_indent_insert')
    let g:ListMode_indent_insert = "<Tab>"
endif

if !exists('g:ListMode_outdent_normal')
    let g:ListMode_outdent_normal = "<S-Tab>"
endif

if !exists('g:ListMode_outdent_insert')
    let g:ListMode_outdent_insert = "<S-Tab>"
endif

if !exists('g:ListMode_newitem_normal')
    let g:ListMode_newitem_normal = "<CR>"
endif

if !exists('g:ListMode_newitem_insert')
    let g:ListMode_newitem_insert = "<CR>"
endif

if !exists('g:ListMode_changetype_normal')
    let g:ListMode_changetype_normal = "<D-8>"
endif

if !exists('g:ListMode_changetype_insert')
    let g:ListMode_changetype_insert = "<D-8>"
endif
" }}}

