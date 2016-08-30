" vim: set fdm=marker et ts=4 sw=4 sts=4:
" listmode.vim - Vim: List mode, especially for pandoc version of markdown
" Author:        bwhelm
" Version:       0.2
" License:       GPL2 or later

if exists('g:ListMode_loaded') || &cp
    finish
endif

let g:ListMode_loaded = 1


" Define commands
command! ListModeToggle call listmode#ToggleListMode()
command! ListModeReformat call listmode#ReformatList()

" Default keymappings {{{1

if !exists('g:vim_listmode_map_prefix')
	let g:vim_listmode_map_prefix = '<Leader>'
endif

if !exists('g:vim_listmode_toggle')
    let g:vim_listmode_toggle = g:vim_listmode_map_prefix."lm"
endif

if !exists('g:vim_listmode_reformat')
    let g:vim_listmode_reformat = g:vim_listmode_map_prefix."lr"
endif

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

if !exists('g:ListMode_folding')
    let g:ListMode_folding = 1
endif

if !exists('g:ListMode_textobj')
    let g:ListMode_textobj = "l"
elseif len(g:ListMode_textobj) != 1
    echohl WarningMsg | echoerr "ERROR: g:ListMode_textobj must be a single character. Setting to 'l'." | echohl None
    let g:ListMode_textobj = "l"
endif

execute "noremap <unique>" g:vim_listmode_toggle ":ListModeToggle<CR>"
execute "noremap <unique>" g:vim_listmode_reformat ":ListModeReformat<CR>"
" }}}

" =============================================================================
" Text Objects -- define these only if vim-textobj-user is loaded
" =============================================================================

if exists('textobj#user#plugin')
    call textobj#user#plugin('listmode', {
    \   '-': {
    \   'select-a-function': 'listmode#CurrentListItemA',
    \   'select-a': 'a' . g:ListMode_textobj,
    \   'select-i-function': 'listmode#CurrentListItemI',
    \   'select-i': 'i' . g:ListMode_textobj,
    \   },
    \ })
endif
