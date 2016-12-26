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
    let g:ListMode_indent_normal = ">>"
endif

if !exists('g:ListMode_indent_insert')
    let g:ListMode_indent_insert = "<C-t>"
endif

if !exists('g:ListMode_outdent_normal')
    let g:ListMode_outdent_normal = "<<"
endif

if !exists('g:ListMode_outdent_insert')
    let g:ListMode_outdent_insert = "<C-d>"
endif

if !exists('g:ListMode_newitem_normal')
    let g:ListMode_newitem_normal = "<CR>"
endif

if !exists('g:ListMode_newitem_insert')
    let g:ListMode_newitem_insert = "<CR>"
endif

if !exists('g:ListMode_changetype_backward_normal')
    let g:ListMode_changetype_backward_normal = g:vim_listmode_map_prefix . "["
endif

if !exists('g:ListMode_changetype_forward_normal')
    let g:ListMode_changetype_forward_normal = g:vim_listmode_map_prefix . "]"
endif

if !exists('g:ListMode_changetype_backward_insert')
    let g:ListMode_changetype_backward_insert = g:vim_listmode_map_prefix . "["
endif

if !exists('g:ListMode_changetype_forward_insert')
    let g:ListMode_changetype_forward_insert = g:vim_listmode_map_prefix . "]"
endif

if !exists('g:ListMode_separator')
    let g:ListMode_separator = "<LocalLeader>-"
endif

execute "noremap <unique>" g:vim_listmode_toggle ":ListModeToggle<CR>"
execute "noremap <unique>" g:vim_listmode_reformat ":ListModeReformat<CR>"

" Default Settings {{{1
if !exists('g:ListMode_folding')
    let g:ListMode_folding = 1
endif

if !exists('g:ListMode_textobj')
    let g:ListMode_textobj = "l"
elseif len(g:ListMode_textobj) != 1
    echohl WarningMsg | echom "ERROR: g:ListMode_textobj must be a single character. Setting to 'l'." | echohl None
    let g:ListMode_textobj = "l"
endif

if !exists('g:ListMode_remap_oO')
    let g:ListMode_remap_oO = 1
endif

if !exists('g:ListMode_unordered_char')
    let g:ListMode_unordered_char = "-"
else
    if g:ListMode_unordered_char != "-" && g:ListMode_unordered_char != "+" && g:ListMode_unordered_char != "*"
        " FIXME: How do I get this warning to be visible to user??
        echohl WarningMsg | echom "WARNING: g:ListMode_unordered_char must be '-', '+', or '*'. Setting to '-'." | echohl None
        let g:ListMode_unordered_char = "-"
    endif
endif

if !exists('g:ListMode_list_rotation_forward')
    " Rotation order. ("ol" = ordered list; "ul" = unordered list; "nl" =
    " numbered lists ("#. "); "el" = special list #2; "dl" = description
    " list.)
    let g:ListMode_list_rotation_forward = {"ol": g:ListMode_unordered_char . " ", "ul": "@. ", "el": "#. ", "nl": "1. ", "empty": "1. "}
endif

if !exists('g:ListMode_list_rotation_backward')
    let g:ListMode_list_rotation_backward = {"nl": "@. ", "el": g:ListMode_unordered_char . " ", "ul": "1. ", "ol": "#. ", "empty": "1. "}
endif
" }}}

" =============================================================================
" Text Objects -- define these only if vim-textobj-user is loaded
" =============================================================================

call textobj#user#plugin('listmode', {
\   '-': {
\   'select-a-function': 'listmode#CurrentListItemA',
\   'select-a': 'a' . g:ListMode_textobj,
\   'select-i-function': 'listmode#CurrentListItemI',
\   'select-i': 'i' . g:ListMode_textobj,
\   },
\ })
