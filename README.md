# ListMode

This plugin allows for easy entry of (ordered or unordered) lists, especially
in markdown or pandoc.

## CONTENTS

    1. Function of ListMode
    2. Overview of Markdown (and Pandoc) Lists
    3. Configuration
    4. Limitations

## FUNCTION OF LISTMODE

ListMode will facilitate entering lists by remapping (by default) "\<CR\>",
"\>\>" and "\<\<" (or "\<C-t\>" and "\<C-d\>" in insert mode) to automatically
create new list items, indent the current list item, or outdent the current
list item. In doing this, the list prefixes are automatically updated to
reflect what the new list item should be. Thus, when in an ordered list,
hitting "\<CR\>" at the end of a list item will create a new list item with the
next numbered item already in place. "\<CR\>" will also split lines when the
cursor is in the middle of a line, and create new items above the current line
when the cursor is at the beginning of the line. If the line is empty (other
than the list prefix), hitting "\<CR\>" will automatically outdent the item
(changing the list type as necessary), or, if the line is not indented, remove
the list prefix.

Similarly, hitting "\>\>" or "\<\<" (or "\<C-t\>" or "\<C-d\>" in insert mode)
will indent or outdent list items, changing the list type as appropriate.

The list type of all siblings of the current item can be changed by typing (by
default) "\<Leader\>[" and "\<Leader\>]"; parents and children will be
unaffected.

The current list can be reformatted from normal mode by typing (by default)
"\<Leader\>lr" (for "Listmode Reformat").

With ListMode on, typing (by default) "\_" in normal mode will move the cursor
to the first text character of the current list item. If the cursor is already
in that position, or if the current line is not a list item, it will behave
like standard "\_" and move the cursor to the first non-blank character in the
line. The mapping for this is set through *g:ListMode_go_to_start_of_line*.

ListMode is toggled on or off from normal mode by typing (by default)
"\<Leader\>lm" (for "ListMode"). When ListMode is toggled on, it saves the
current mappings for "\<CR\>", "\>\>", "\<\<", "\<C-t\>", "\<C-d\>",
"\<Leader\>[" and "\<Leader\>]" and remaps them to ListMode functions. When it
is toggled off, the old mappings are restored.

ListMode can be configured to remap "o" and "O" to insert list headers as
appropriate. This option is set through *g:ListMode_remap_oO*.

ListMode defines a list item text object, so that in normal mode typing "cil"
will delete the current list item, not including the list prefix, and put vim
into insert mode. Similarly, typing "dal" in normal mode will delete the
current list item including the list prefix. The character that designates the
list text object is defined by *g:ListMode_textobj* and is "l" by default. This
feature requires that the vim-textobj-user plugin
(<http://www.vim.org/scripts/script.php?script_id=2100>) be installed.


## OVERVIEW OF MARKDOWN (AND PANDOC) LISTS

Markdown aims to be a human-readable syntax for writing structured documents
that can be easily converted to html. While there is no universally accepted
specification of markdown, CommonMark (\<commonmark.org\>) aims to do this.
According to CommonMark, markdown lists take the following forms:

Unordered lists: start with either "-" or "*", some whitespace (one or more
spaces or tabs), and the list item. For example:

    - Item 1
    - Item 2

or

    * Item 2
    * Item 2

Ordered lists: start with a number, followed by a period (".") or a right
parenthesis (")") and some whitespace. For example:

    1. Item 1
    2. Item 2

or

    1) Item 1
    2) Item 2

In addition, ordered and unordered lists can be nested by indenting sub-lists
with either tab or 4 spaces:

    1. Item 1
        - Sub-item 1
        - Sub-item 2
            1. Sub-sub-item 1
            2. Sub-sub-item 2
        - Sub-item 3
    2. Item 2

Pandoc (\<pandoc.org\>) extends CommonMark's lists by allowing unordered lists
also to start with "+", and allowing ordered lists also to start with a number
enclosed in parentheses followed by whitespace, like: "(1) ". In addition,
pandoc adds several other list types. First, ordered lists can begin with
"#. "; these behave otherwise just like standard ordered lists.

A second type of ordered list -- an "example list" is more special. In place of
a number, they use "@", which is optionally followed by a key (a sequence of
letters (A-Za-z), numbers (0-9) or a hyphen ("-") or underscore ("\_"). For
example:

    @. Item 1
    @key. Item 2
    (@) Item 3
    (@my_very_long_key) Item 4

In pandoc, example lists allow cross-referencing of keyed list numbers.
Moreover, example lists are numbered sequentially throughout the document,
irrespective of whether they are interrupted by other text. Thus (continuing
the list from above):

    @. Item 5

Finally, pandoc adds "definition lists", which involve two lines. The first
line contains the term being defined; the second line contains either a colon
(":") or tilde ("~"), some whitespace, and the definition. For example:

    Term
    : Definition.

Note that definition lists *must* be surrounded by blank lines (containing only
whitespace) before and after. This is not true of other list types. For more
details, see \<http://pandoc.org/MANUAL.html#lists\>.


## CONFIGURATION

The following variables can be configured (with defaults given):

- **g:vim_listmode_map_prefix** = '\<Leader\>'. This is used by the next two
  settings.

- **g:vim_listmode_toggle** = **g:vim_listmode_map_prefix** . "lm". This
  toggles between listmode key mappings and standard key mappings, but only in
  normal mode.

- **g:vim_listmode_reformat** = **g:vim_listmode_map_prefix** . "lr". This
  reformats the current list, but only in normal mode.

- **g:ListMode_indent_normal** = "\>\>". This indents the current line, leaving
  the cursor where it was in the text. Used for normal mode.

- **g:ListMode_indent_insert** = "\<\<". This indents the current line, leaving
  the cursor where it was in the text. Used for insert mode.

- **g:ListMode_outdent_normal** = "\<C-t\>". This outdents the current line,
  leaving the cursor where it was in the text. Used for normal mode.

- **g:ListMode_outdent_insert** = "\<C-d\>". This outdents the current line,
  leaving the cursor where it was in the text. Used for insert mode.

- **g:ListMode_newitem_normal** = "\<CR\>". This inserts a new list item at the
  same level. If the cursor is in the main text, the text is split at the
  cursor, with the text after the cursor appearing on the next line. If the
  cursor is in the list prefix, a new list item is created above the current
  line. For normal mode.

- **g:ListMode_newitem_insert** = "\<CR\>". This inserts a new list item at the
  same level. If the cursor is in the main text, the text is split at the
  cursor, with the text after the cursor appearing on the next line. If the
  cursor is in the list prefix, a new list item is created above the current
  line. For insert mode.

- **g:ListMode_changetype_backward_normal**="<Leader>[ This changes the list
type of all siblings of the current list item. For normal mode. The list of
rotations is determined by *g:ListMode_list_rotation_backward*.

- **g:ListMode_changetype_forward_normal**="<Leader>]" This changes the list
type of all siblings of the current list item. For normal mode. The list of
rotations is determined by *g:ListMode_list_rotation_forward*.

- **g:ListMode_changetype_backward_insert**="<Leader>[" This changes the list
type of all siblings of the current list item. For insert mode. The list of
rotations is determined by *g:ListMode_list_rotation_backward*.

- **g:ListMode_changetype_forward_insert**="<Leader>]" This changes the list
type of all siblings of the current list item. For insert mode. The list of
rotations is determined by *g:ListMode_list_rotation_forward*.

- **g:ListMode_separator_mapping** = "<LocalLeader>-". This inserts
  "<!-- --><CR><CR>", only in insert mode.

- **g:ListMode_go_to_start_of_line="\_"** This defines the default keymapping
  for moving to the start of the current list item.

- **g:ListMode_remap_oO**=1. This determines whether invoking ListMode remaps
  "o" and "O" to insert lines below or above the current line with the
  appropriate list header.

- **g:ListMode_textobj**="l". This changes the character that designates the list
  text object.

- **g:ListMode_unordered_char**="-". This defines the default prefix for
  unordered lists. Possible values are "-", "+", and "*".

- **g:ListMode_list_rotation_forward**={"ol": g:ListMode_unordered_char . " ",
  "ul": "@. ", "el": "#. ", "nl": "1. ", "empty": "1. "} This defines the
  default rotation of list types in the forward direction, where "ol" =
  ordered list; "ul" = unordered list; "nl" = numbered lists ("#. "); "el" =
  special list #2; "dl" = description list.

- **g:ListMode_list_rotation_backward**={"nl": "@. ", "el":
  g:ListMode_unordered_char . " ", "ul": "1. ", "ol": "#. ", "empty": "1. "}
  This defines the default rotation of list types in the forward direction,
  where "ol" = ordered list; "ul" = unordered list; "nl" = numbered lists ("#.
  "); "el" = special list #2; "dl" = description list.

## LIMITATIONS

1. ListMode assumes lines are soft wrapped, so that each line contains a single
   list item. If list items span more than one line, lists will not be
   identified properly.

2. ListMode automatically reformats lists to a common style, using "-" rather
   than "\*" or "+" for unordered lists and "1. " rather than "1) " or "(1) "
   for ordered lists, for example. What style this is is hard-coded. It should
   be a user-defined option.

3. Pandoc definition lists can have multiple definitions, and the term and
   definition can be separated by blank lines. These options are not supported.
