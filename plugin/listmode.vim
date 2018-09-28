" vim: set fdm=marker et ts=4 sw=4 sts=4:
" listmode.vim - Vim: List mode, especially for pandoc version of markdown
" Author:        bwhelm
" Version:       0.2
" License:       GPL2 or later

if exists('g:ListMode_loaded') || &compatible
    finish
endif

let g:ListMode_loaded = 1


" Define commands
command! ListModeToggle call listmode#ToggleListMode()
command! -range=% ListModeReformat call listmode#ReformatList(<line1>,<line2>)

" Default keymappings {{{1

let g:vim_listmode_map_prefix = get(g:, 'vim_listmode_map_prefix', '<Leader>')
let g:vim_listmode_toggle = get(g:, 'vim_listmode_toggle', g:vim_listmode_map_prefix.'lm')
let g:vim_listmode_reformat = get(g:, 'vim_listmode_reformat', g:vim_listmode_map_prefix.'lr')
let g:ListMode_indent_normal = get(g:, 'ListMode_indent_normal', '>>')
let g:ListMode_indent_insert = get(g:, 'ListMode_indent_insert', '<C-t>')
let g:ListMode_outdent_normal = get(g:, 'ListMode_outdent_normal', '<<')
let g:ListMode_outdent_insert = get(g:, 'ListMode_outdent_insert', '<C-d>')
let g:ListMode_newitem_normal = get(g:, 'ListMode_newitem_normal', '<CR>')
let g:ListMode_newitem_insert = get(g:, 'ListMode_newitem_insert', '<CR>')
let g:ListMode_changetype_backward_normal = get(g:, 'ListMode_changetype_backward_normal', g:vim_listmode_map_prefix . '[')
let g:ListMode_changetype_forward_normal = get(g:, 'ListMode_changetype_forward_normal', g:vim_listmode_map_prefix . ']')
let g:ListMode_changetype_backward_insert = get(g:, 'ListMode_changetype_backward_insert', g:vim_listmode_map_prefix . '[')
let g:ListMode_changetype_forward_insert = get(g:, 'ListMode_changetype_forward_insert', g:vim_listmode_map_prefix . ']')
let g:ListMode_separator = get(g:, 'ListMode_separator', '<LocalLeader>-')
let g:ListMode_go_to_start_of_line = get(g:, 'ListMode_go_to_start_of_line', '_')
let g:ListMode_insert_at_start = get(g:, 'ListMode_insert_at_start', 'I')

execute 'noremap <silent> <unique>' g:vim_listmode_toggle ':ListModeToggle<CR>'
execute 'noremap <silent> <unique>' g:vim_listmode_reformat ':ListModeReformat<CR>'

" Default Settings {{{1
let g:ListMode_folding = get(g:, 'ListMode_folding', 1)
let g:ListMode_remap_oO = get(g:, 'ListMode_remap_oO', 1)

let g:ListMode_textobj = get(g:, 'ListMode_textobj', 'l')
if len(g:ListMode_textobj) != 1
    echohl WarningMsg | echom "ERROR: g:ListMode_textobj must be a single character. Setting to 'l'." | echohl None
    let g:ListMode_textobj = 'l'
endif

let g:ListModeTree_textobj = get(g:, 'ListModeTree_textobj', 'L')
if len(g:ListModeTree_textobj) != 1
    echohl WarningMsg | echom "ERROR: g:ListModeTree_textobj must be a single character. Setting to 'l'." | echohl None
    let g:ListModeTree_textobj = 'L'
endif

let g:ListMode_unordered_char = get(g:, 'ListMode_unordered_char', '-')
if g:ListMode_unordered_char !=# '-' && g:ListMode_unordered_char !=# '+' && g:ListMode_unordered_char !=# '*'
    " FIXME: How do I get this warning to be visible to user??
    echohl WarningMsg
    echom "WARNING: g:ListMode_unordered_char must be '-', '+', or '*'. Setting to '-'."
    echohl None
    let g:ListMode_unordered_char = '-'
endif

" Rotation order. ("ol" = ordered list; "ul" = unordered list; "nl" =
" numbered lists ("#. "); "el" = special list #2; "dl" = description
" list; "te" = text in list.)
let g:ListMode_list_rotation_forward = get(g:, 'ListMode_list_rotation_forward',
    \ {'ol': g:ListMode_unordered_char . ' ', 'ul': '@. ', 'el': '#. ',
    \  'nl': '1. ', 'empty': '1. ', 'te': '1. '})
let g:ListMode_list_rotation_backward = get(g:, 'ListMode_list_rotation_backward',
    \ {'nl': '@. ', 'el': g:ListMode_unordered_char . ' ', 'ul': '1. ',
    \  'ol': '#. ', 'empty': '1. ', 'te': '1. '})
" }}}

" =============================================================================
" Text Objects -- define these only if vim-textobj-user is loaded
" =============================================================================

try
    call textobj#user#plugin('listmode', {
    \   'listitem': {
            \ 'select-a-function': 'listmode#CurrentListItemA',
            \ 'select-a': 'a' . g:ListMode_textobj,
            \ 'select-i-function': 'listmode#CurrentListItemI',
            \ 'select-i': 'i' . g:ListMode_textobj,
        \ },
    \   'listtree': {
            \ 'select-a-function': 'listmode#CurrentListTreeA',
            \ 'select-a': 'a' . g:ListModeTree_textobj,
            \ 'select-i-function': 'listmode#CurrentListTreeI',
            \ 'select-i': 'i' . g:ListModeTree_textobj,
        \ },
    \ })
endtry
