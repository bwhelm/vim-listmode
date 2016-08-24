# Vim Listmode

The aim of this plugin is to allow for easy entry of markdown lists.


## Configuration

The following variables can be configured (with defaults given):

- g:vim_listmode_map_prefix = '<leader>'. This is used by the next two settings.

- g:vim_listmode_toggle = g:vim_listmode_map_prefix."lm". This toggles between listmode key mappings and standard key mappings, but only in normal mode.

- g:vim_listmode_reformat = g:vim_listmode_map_prefix."lr". This reformats the current list, but only in normal mode.

- g:ListMode_indent_normal = "<Tab>". This indents the current line, leaving the cursor where it was in the text. Used for normal mode.

- g:ListMode_indent_insert = "<Tab>". This indents the current line, leaving the cursor where it was in the text. Used for insert mode.

- g:ListMode_outdent_normal = "<S-Tab>". This outdents the current line, leaving the cursor where it was in the text. Used for normal mode.

- g:ListMode_outdent_insert = "<S-Tab>". This outdents the current line, leaving the cursor where it was in the text. Used for insert mode.

- g:ListMode_newitem_normal = "<CR>". This inserts a new list item at the same level. If the cursor is in the main text, the text is split at the cursor, with the text after the cursor appearing on the next line. If the cursor is in the list prefix, a new list item is created above the current line. For normal mode.

- g:ListMode_newitem_insert = "<CR>". This inserts a new list item at the same level. If the cursor is in the main text, the text is split at the cursor, with the text after the cursor appearing on the next line. If the cursor is in the list prefix, a new list item is created above the current line. For insert mode.

- g:ListMode_changetype_normal = "<D-8>". This changes the list type of all siblings of the current list item. For normal mode.

- g:ListMode_changetype_insert = "<D-8>". This changes the list type of all siblings of the current list item. For insert mode.
