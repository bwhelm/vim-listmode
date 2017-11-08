" vim: set fdm=marker et ts=4 sw=4 sts=4:

" =============================================================================
" Cope with mappings
" =============================================================================

function! listmode#RestoreMapping(mapDict, key, mode) abort  "{{{1
    " Restores mapping saved in mapDict
    execute a:mode . 'unmap <buffer> ' . a:key
    if !empty(a:mapDict)
        execute (a:mapDict.noremap ? a:mapDict.mode . 'noremap' : a:mapDict.mode .'map') .
            \ (a:mapDict.buffer ? ' <buffer>' : '') .
            \ (a:mapDict.expr ? ' <expr>' : '') .
            \ (a:mapDict.nowait ? ' <nowait>' : '') .
            \ (a:mapDict.silent ? ' <silent>' : '') .
            \ ' ' . a:mapDict.lhs .
            \ ' ' . a:mapDict.rhs
    endif
endfunction

function! listmode#ListModeOn(showMessages) abort  "{{{1
    " Turn listmode on -- set all mappings
    let b:listmode_indent_normal = 
            \ maparg(g:ListMode_indent_normal, 'n', 0, 1)
    let b:listmode_indent_insert =
            \ maparg(g:ListMode_indent_insert, 'i', 0, 1)
    let b:listmode_outdent_normal =
            \ maparg(g:ListMode_outdent_normal, 'n', 0, 1)
    let b:listmode_outdent_insert =
            \ maparg(g:ListMode_outdent_insert, 'i', 0, 1)
    let b:listmode_newitem_normal =
            \ maparg(g:ListMode_newitem_normal, 'n', 0, 1)
    let b:listmode_newitem_insert =
            \ maparg(g:ListMode_newitem_insert, 'i', 0, 1)
    let b:listmode_changetype_forward_normal =
            \ maparg(g:ListMode_changetype_forward_normal, 'n', 0, 1)
    let b:listmode_changetype_backward_normal =
            \ maparg(g:ListMode_changetype_backward_normal, 'n', 0, 1)
    let b:listmode_changetype_forward_insert =
            \ maparg(g:ListMode_changetype_forward_insert, 'i', 0, 1)
    let b:listmode_changetype_backward_insert =
            \ maparg(g:ListMode_changetype_backward_insert, 'i', 0, 1)
    let b:listmode_go_to_start_of_line =
            \ maparg(g:ListMode_go_to_start_of_line, 'n', 0, 1)
    execute 'nnoremap <buffer> <silent>'
            \ g:ListMode_indent_normal ':call listmode#IndentLine()<CR>'
    execute 'inoremap <buffer> <silent>'
            \ g:ListMode_indent_insert "<C-\\><C-o>:call listmode#IndentLine()<CR>"
    execute 'nnoremap <buffer> <silent>'
            \ g:ListMode_outdent_normal ':call listmode#OutdentLine()<CR>'
    execute 'inoremap <buffer> <silent>'
            \ g:ListMode_outdent_insert "<C-\\><C-o>:call listmode#OutdentLine()<CR>"
    execute 'nnoremap <buffer> <silent>'
            \ g:ListMode_newitem_normal ':call listmode#NewListItem()<CR>'
    execute 'inoremap <buffer> <silent>'
            \ g:ListMode_newitem_insert "<C-\\><C-o>:call listmode#NewListItem()<CR>"
    execute 'nnoremap <buffer> <silent>'
            \ g:ListMode_changetype_forward_normal ':call listmode#ChangeListTypeForward()<CR>'
    execute 'nnoremap <buffer> <silent>'
            \ g:ListMode_changetype_backward_normal ':call listmode#ChangeListTypeBackward()<CR>'
    execute 'inoremap <buffer> <silent>'
            \ g:ListMode_changetype_forward_insert "<C-\\><C-o>:call listmode#ChangeListTypeForward()<CR>"
    execute 'inoremap <buffer> <silent>'
            \ g:ListMode_changetype_backward_insert "<C-\\><C-o>:call listmode#ChangeListTypeBackward()<CR>"
    execute 'nnoremap <buffer> <silent>'
            \ g:ListMode_go_to_start_of_line ':call listmode#GoToStartOfListItem()<CR>'
    if g:ListMode_remap_oO
        let b:listmode_o_mapping = maparg('o', 'n', 0, 1)
        let b:listmode_O_mapping = maparg('O', 'n', 0, 1)
        " Note: We want these to involve ListMode's <CR>, so shouldn't use
        " nnoremap`.
        nmap <buffer> o A<CR>
        nmap <buffer> O 0ho
    endif
    let b:listmode_separator_mapping = maparg(g:ListMode_separator, 'i', 0, 1)
    execute 'inoremap <buffer> <silent>' g:ListMode_separator '<!-- --><CR><CR>'

    let b:listmode = 1

    " Set up folding for later restore
    if g:ListMode_folding != 0
        let b:oldfoldmethod=&foldmethod
        let b:oldfoldexpr=&foldexpr
        let b:oldfoldtext=&foldtext
        setlocal foldmethod=expr
        setlocal foldexpr=listmode#GetListModeFold(v:lnum)
        setlocal foldtext=listmode#FoldText()
    endif
    if a:showMessages
        echohl Comment
        echo 'Now entering vim list mode'
        echohl None
    endif
endfunction

function! listmode#ListModeOff(showMessages) abort  "{{{1
    " Turn listmode off and restore mappings
    call listmode#RestoreMapping(b:listmode_indent_normal,
            \ g:ListMode_indent_normal, 'n')
    call listmode#RestoreMapping(b:listmode_indent_insert,
            \ g:ListMode_indent_insert, 'i')
    call listmode#RestoreMapping(b:listmode_outdent_normal,
            \ g:ListMode_outdent_normal, 'n')
    call listmode#RestoreMapping(b:listmode_outdent_insert,
            \ g:ListMode_outdent_insert, 'i')
    call listmode#RestoreMapping(b:listmode_newitem_normal,
            \ g:ListMode_newitem_normal, 'n')
    call listmode#RestoreMapping(b:listmode_newitem_insert,
            \ g:ListMode_newitem_insert, 'i')
    call listmode#RestoreMapping(b:listmode_changetype_forward_normal,
            \ g:ListMode_changetype_forward_normal, 'n')
    call listmode#RestoreMapping(b:listmode_changetype_backward_normal,
            \ g:ListMode_changetype_backward_normal, 'n')
    call listmode#RestoreMapping(b:listmode_changetype_forward_insert,
            \ g:ListMode_changetype_forward_insert, 'i')
    call listmode#RestoreMapping(b:listmode_changetype_backward_insert,
            \ g:ListMode_changetype_backward_insert, 'i')
    call listmode#RestoreMapping(b:listmode_go_to_start_of_line,
            \ g:ListMode_go_to_start_of_line, 'n')
    if g:ListMode_remap_oO
        call listmode#RestoreMapping(b:listmode_o_mapping, 'o', 'n')
        call listmode#RestoreMapping(b:listmode_O_mapping, 'O', 'n')
    endif
    call listmode#RestoreMapping(b:listmode_separator_mapping,
            \ g:ListMode_separator, 'i')
    let b:listmode=0

    " Restore folding
    if g:ListMode_folding != 0
        let &l:foldmethod=b:oldfoldmethod
        let &l:foldexpr=b:oldfoldexpr
        let &l:foldtext=b:oldfoldtext
    endif
    if a:showMessages
        echohl Comment
        echo 'Now leaving vim list mode'
        echohl None
    endif
endfunction

function! listmode#ToggleListMode(...) abort  "{{{1
    " Switches between mappings
    if a:0
        let l:showMessages = 0
    else
        let l:showMessages = 1
    endif
    if !exists('b:listmode')
        let b:listmode = 0  " Start with listmode off by default with new buffer
    endif
    if b:listmode        " Need to swap keymappings back
        call listmode#ListModeOff(l:showMessages)
    else                " Need to save keymappings and generate new ones
        call listmode#ListModeOn(l:showMessages)
    endif
endfunction
" }}}

" =============================================================================
" Main ListMode code
" =============================================================================

function! s:IndentText() abort "{{{1
    " Using spaces or tabs?
    if &expandtab
        return '    '
    else
        return "\t"
    endif
endfunction

function! s:IsUList(line) abort  "{{{1
    " Check if line is unordered list
    return match(a:line, '^\s*[-*+]\s') >= 0
endfunction

function! s:IsOList(line) abort  "{{{1
    " Check if line is ordered list
    return match(a:line, '^\s*(\?\d\+[.)]\s') >= 0
endfunction

function! s:IsNumberedList(line) abort  "{{{1
    " Check if line is special list 1
    return match(a:line, '^\s*#\.\s') >= 0
endfunction

function! s:IsExampleList(line) abort  "{{{1
    " Check if line is special list 2
    return match(a:line, '^\s*(\?@[A-z0-9\-_]*[.)]\s') >= 0
endfunction

function! s:FindExampleListKey(line) abort  "{{{1
    " Find the key for special list 2 (such as: "@key. item")
    let l:myMatch = matchlist(a:line, '^\s*(\?\(@[A-z0-9\-_]*\)[.)]\s')
    return l:myMatch[1] . '. '
endfunction

function! s:IsDescList(lines) abort  "{{{1
    " Check if lines (list of single lines) contains a description list
    let l:text = join(a:lines, "\n")
    return match(l:text, '^\s*\S.*\n\s*[:~]\s\+\S') >= 0
endfunction

function! s:IsWhiteSpace(line) abort  "{{{1
    " Check if line contains only whitespace
    return a:line =~# '^\s*$'
endfunction

function! s:IsListSeparator(line) abort  "{{{1
    
    " Check if line is a list separator (`<!-- -->`)
    return a:line =~# '^\s*<!-- -->\s*$'
endfunction

function! s:IsIndentedText(line) abort  "{{{1
    
    " Check if line is indented text -- not a list, but not something that
    " breaks a list, either.
    return a:line =~# '^\(\t\|    \)'
endfunction

function! s:FindLevel(line) abort  "{{{1
    " Find indentation level of line
    let l:nonSpaceIndex = match(a:line, '\S')
    let l:initialSpaces = a:line[:l:nonSpaceIndex]
    let l:initialSpaces = substitute(l:initialSpaces, "\t", '    ', 'g')
    return len(l:initialSpaces) / 4
endfunction

function! s:FindListType(line) abort  "{{{1
    " Find type of list of current line. ("ol" = ordered list; "ul" = unordered
    " list; "nl" = numbered lists ("#. "); "el" = special list #2; "dl" =
    " description list; "te" = text in list.)
    if <SID>IsWhiteSpace(a:line)
        return 'empty'
    elseif <SID>IsOList(a:line)
        return 'ol'
    elseif <SID>IsUList(a:line)
        return 'ul'
    elseif <SID>IsNumberedList(a:line)
        return 'nl'
    elseif <SID>IsExampleList(a:line)
        return 'el'
    elseif <SID>IsListSeparator(a:line)
        return 'ls'
    elseif a:line =~# '^\s*[~:]\s'
        return 'dl'
    elseif <SID>IsIndentedText(a:line)
        return 'te'
    else
        return 0  " If we know it's a list item, this will be a "dl"
    endif
endfunction

function! s:IsList(line) abort  "{{{1
    let l:listType = <SID>FindListType(a:line)
    return l:listType !=# '0' && l:listType !=# 'empty' && l:listType !~# 'te'
endfunction

function! s:LineContent(line) abort  "{{{1
    " Return content of line, stripped of any white space and list indicators at
    " the beginning of the line.
    if index(['ol','ul','nl','el','empty'], <SID>FindListType(a:line)) >= 0
        let l:lineStart = match(a:line,
                \ '\(^\s*\((\?[0-9#]\+[.)]\|(\?@[A-z0-9\-_]*[.)]\|[-*+]\)\s\+\)\@<=.*')
        return a:line[l:lineStart :]
    else  " Must be description list or list separator or nolist
        let l:lineStart = match(a:line, '\S')
        if l:lineStart == -1
            return ''
        else
            return a:line[l:lineStart :]
        endif
    endif
endfunction

function! s:FindListScope() abort  "{{{1
    " Find set of lines around cursor that is a list
    let l:lineNumber = s:lineNumber
    let l:listType = <SID>FindListType(s:bufferText[l:lineNumber])
    let l:begin = 0  " Catches case when cursor is at start of file, which is also start of list
    let l:end = len(s:bufferText) - 1  " Catches case in which cursor is at eof, which is also eol
    if l:listType ==# 'dl'
        let l:lineNumber -= 1  " At second line of DL; go back one line.
    elseif empty(l:listType)
        if <SID>IsDescList(s:bufferText[l:lineNumber - 1:l:lineNumber + 2])
            let l:listType = 'dl'
        endif
    endif
    if !empty(l:listType)  " If current line is empty or a list line...
        " Search backwards
        let l:lineIndex = l:lineNumber
        " l:listStructure is a dictionary of lists: {lineno: [listType, listLevel]}
        let l:listStructure = {}
        while l:lineIndex >= 0
            let l:listType = <SID>FindListType(s:bufferText[l:lineIndex])
            let l:lineLevel = <SID>FindLevel(s:bufferText[l:lineIndex])
            if l:listType ==# 'ls' && l:lineLevel == 0
                let l:begin = max([l:lineIndex + 1, 0])
                break
            elseif !empty(l:listType) && l:listType !=# 'dl'
                let l:listStructure[l:lineIndex] = [l:listType, l:lineLevel]
                let l:lineIndex -= 1
            elseif <SID>IsDescList(s:bufferText[max([0, l:lineIndex - 1]):l:lineIndex
                        \ + 2 + (l:lineIndex == -1)])
                let l:listStructure[l:lineIndex - 1] =
                        \ ['dl', <SID>FindLevel(s:bufferText[l:lineIndex])]
                let l:listStructure[l:lineIndex] =
                        \ ['dl', <SID>FindLevel(s:bufferText[l:lineIndex])]
                " TODO: Need to check for more than one definition in DL
                let l:lineIndex -= 2
            else
                let l:begin = max([l:lineIndex + 1, 0])
                break
            endif
        endwhile
        " Search forwards
        let l:lineIndex = l:lineNumber + 1
        while l:lineIndex < len(s:bufferText)
            let l:listType = <SID>FindListType(s:bufferText[l:lineIndex])
            let l:lineLevel = <SID>FindLevel(s:bufferText[l:lineIndex])
            if l:listType ==# 'ls' && l:lineLevel == 0
                let l:end = l:lineIndex -1
                break
            elseif !empty(l:listType)
                let l:listStructure[l:lineIndex] = [l:listType, l:lineLevel]
                let l:lineIndex += 1
            elseif <SID>IsDescList(s:bufferText[max([0, l:lineIndex - 1]):l:lineIndex
                    \ + 2 + (l:lineIndex == -1)])
                let l:listStructure[l:lineIndex] =
                        \ ['dl', <SID>FindLevel(s:bufferText[l:lineIndex])]
                let l:listStructure[l:lineIndex + 1] =
                        \ ['dl', <SID>FindLevel(s:bufferText[l:lineIndex])]
                " TODO: Need to check for more than one definition in DL
                let l:lineIndex += 2
            else
                let l:end = l:lineIndex - 1
                break
            endif
        endwhile
        " Edge case: Don't consider it a list if current line is empty and at
        " the beginning of the list.
        if <SID>IsWhiteSpace(s:bufferText[l:lineNumber]) && l:lineNumber == l:begin
            return [0, 0, []]
        endif
        " Edge case: Don't consider a list if l:begin == l:end
        if l:begin == l:end
            return [0, 0, []]
        endif
        " Edge case: Don't consider series of blank lines a list.
        let l:realList = 0
        for l:line in s:bufferText[l:begin : l:end]
            if !<SID>IsWhiteSpace(l:line)
                let l:realList = 1
                break
            endif
        endfor
        if l:realList
            return [l:begin, min([l:end, len(s:bufferText) - 1]), l:listStructure]
        else
            return [0, 0, []]
        endif
    else
        return [0, 0, []]
    endif
endfunction

function! s:PlaceCursor(line, prefix, column) abort  "{{{1
    " PlaceCursor() will take a line, a prefix to be added to that line's content,
    " and a cursor position of the original line, and calculate a new cursor
    " position with the prefix added.
    let l:lineContent = <SID>LineContent(a:line)
    let l:linePrefixLength = len(a:line) - len(l:lineContent)
    if l:linePrefixLength < a:column  " If cursor is placed after start of line content
        let l:cursorColumn = len(a:prefix) - l:linePrefixLength + a:column
    else
        let l:cursorColumn = len(a:prefix) + 1
    endif
    return l:cursorColumn
endfunction

function! s:InitializeListFunctions() abort  "{{{1
    
    " Set variables for common list functions
    let s:bufferText = getline(0,'$')
    let [s:bufferNumber, s:lineNumber, s:cursorColumn, s:cursorOffset] = getpos('.')
    let s:lineNumber -= 1
    let s:line = s:bufferText[s:lineNumber]
    let s:currentLineLevel = <SID>FindLevel(s:line)
    if exists('s:listStructure')
        unlet s:listStructure
    endif
    let [s:listBeginLineNumber, s:listEndLineNumber, s:listStructure] =
            \ <SID>FindListScope()
    if s:listEndLineNumber != 0  " Currently in a list...
        let [s:currentListType, s:currentListNumbering] =
                \ s:listStructure[s:lineNumber]
    else  " Not in a list...
        let s:currentListType = 'nolist'
        let s:currentListNumbering = 0
    endif
    " To convert from listType to the needed (pandoc) markdown
    let s:listDef = {'ol': '1. ', 'ul': g:ListMode_unordered_char . ' ',
            \ 'nl': '#. ', 'el': '@. ', 'empty': '', 'dl': '',
            \ 'nolist': '', 'ls': '', 'te': ''} 
endfunction

function! listmode#ReformatList() abort  "{{{1
    " Finds list surrounding current cursor location and reformats it
    call <SID>InitializeListFunctions()
    if s:listEndLineNumber == 0  " Not in a list!
        return
    endif
    " l:levelRecord is a list of ordered pairs: ("list type", number), where 
    " number designates the current count for ordered lists.
    let l:levelRecord = []
    " Initialize 20 levels of emptiness in levelRecord
    for l:i in range(20)
        let l:levelRecord += [['empty', 0]]
    endfor
    let l:listSeparatorFlag = 0
    let l:previousLevel = -1
    let l:newCursorColumn = s:cursorColumn
    let l:newList = []
    for l:key in range(s:listBeginLineNumber, s:listEndLineNumber)
        let [l:listType, l:listLevel] = s:listStructure[l:key]
        " If l:listType == "empty", I want to leave it alone, so that gets
        " skipped in next conditional.
        if index(['ul', 'ol', 'nl', 'el', 'dl', 'ls', 'te'], l:listType) >= 0
            let [l:LRType, l:LRNumber] = l:levelRecord[l:listLevel]
            if l:listLevel > l:previousLevel  " Beginning of sublist
                if l:listType ==# 'ol'
                    let l:levelRecord[l:listLevel] = ['ol', 1]
                else
                    let l:levelRecord[l:listLevel] = [l:listType, 0]
                endif
            elseif l:listLevel == l:previousLevel  " List sibling
                if l:LRType ==# 'ol' && l:listType !=# 'ls'
                    let l:levelRecord[l:listLevel] = ['ol', l:LRNumber + 1]
                endif
            elseif l:listLevel < l:previousLevel  " List parent
                if l:LRType ==# 'empty'
                    if l:listType ==# 'ol'
                        let l:levelRecord[l:listLevel] = ['ol', 1]
                    else
                        let l:levelRecord[l:listLevel] = [l:listType, 0]
                    endif
                else
                    if l:LRType ==# 'ol'
                        let l:levelRecord[l:listLevel] = ['ol', l:LRNumber + 1]
                    endif
                endif
            endif
            " Now need to construct list item
            let [l:LRType, l:LRNumber] = l:levelRecord[l:listLevel]
            if l:listSeparatorFlag && l:listType !=# 'empty'
                let l:LRType = l:listType
                if l:listType ==# 'ol'
                    let l:LRNumber = 1
                else
                    let l:LRNumber = 0
                endif
                let l:levelRecord[l:listLevel] = [l:LRType, l:LRNumber]
                let l:listSeparatorFlag = 0
            endif
            let l:itemText = <SID>LineContent(s:bufferText[l:key])
            let l:newItemPrefix = repeat(s:IndentText(), l:listLevel)
            if l:listType ==# 'ls'
                let l:listSeparatorFlag = 1
            elseif l:LRType ==# 'ol'
                let l:newItemPrefix .= l:LRNumber . '. '
            elseif l:LRType ==# 'el'
                if <SID>IsExampleList(s:bufferText[l:key])
                    let l:newItemPrefix .= <SID>FindExampleListKey(s:bufferText[l:key])
                else
                    let l:newItemPrefix .= s:listDef[l:LRType]
                endif
            else
                let l:newItemPrefix .= s:listDef[l:LRType]
            endif
            let l:newLine = l:newItemPrefix . l:itemText
            if l:key == s:lineNumber
                let l:newCursorColumn = <SID>PlaceCursor(s:bufferText[l:key],
                        \ l:newItemPrefix, s:cursorColumn)
            endif
            " Next line takes way too much time! Instead, store everything in
            " a list and change in the buffer once at the end
            " call setline(l:key + 1, l:newLine)
            call add(l:newList, l:newLine)
            let l:previousLevel = l:listLevel
        else
            " let l:itemText = <SID>LineContent(s:bufferText[l:key])
            call add(l:newList, s:bufferText[l:key])
        endif
    endfor
    call setline(s:listBeginLineNumber + 1, l:newList)
    call setpos('.', [s:bufferNumber, s:lineNumber + 1,
                \ l:newCursorColumn, s:cursorOffset])
endfunction

function! listmode#IndentLine() abort  "{{{1
    " Indent current line, changing list type of lines as appropriate
    call <SID>InitializeListFunctions()
    let l:prefix = repeat(s:IndentText(), <SID>FindLevel(s:line) + 1)
    if s:currentListType ==# 'el'
        let l:prefix .= <SID>FindExampleListKey(s:line)
    else
        let l:prefix .= s:listDef[s:currentListType]
    endif
    let l:newLine = l:prefix
    if match(s:line, '\S') >= 0
        let l:newLine .= <SID>LineContent(s:line)
    endif
    let l:newCursorColumn = <SID>PlaceCursor(s:line, l:prefix, s:cursorColumn)
    call setline(s:lineNumber + 1, l:newLine)
    call setpos('.', [s:bufferNumber, s:lineNumber + 1, l:newCursorColumn, s:cursorOffset])
    call listmode#ReformatList()
endfunction

function! listmode#OutdentLine() abort  "{{{1
    " Outdent current line, changing list type of lines as appropriate
    call <SID>InitializeListFunctions()
    if s:currentLineLevel > 0  " We need to outdent
        let l:prefix = repeat(s:IndentText(), <SID>FindLevel(s:line) - 1)
        if s:currentListType ==# 'el'
            let l:prefix .= <SID>FindExampleListKey(s:line)
        else
            let l:prefix .= s:listDef[s:currentListType]
        endif
        let l:newLine = l:prefix
        if match(s:line, '\S') >= 0
            let l:newLine .= <SID>LineContent(s:line)
        endif
        let l:newCursorColumn = <SID>PlaceCursor(s:line, l:prefix, s:cursorColumn)
    else
        echohl WarningMsg
        echo 'Cannot outdent any further!'
        echohl None
        return
    endif
    call setline(s:lineNumber + 1, l:newLine)
    call setpos('.', [s:bufferNumber, s:lineNumber + 1, l:newCursorColumn, s:cursorOffset])
    call listmode#ReformatList()
endfunction

function! s:ChangeListType(listRotation) abort  "{{{1
    " ChangeListType() will search backwards and forwards in theList to find all
    " siblings of the current line and will change them to a given list type.
    " a:listRotation specifies how list types rotate: ordered lists become
    " unordered lists; everything else becomes an ordered list.    
    call <SID>InitializeListFunctions()
    if s:listEndLineNumber == 0  " Not a list item...
        let l:thisLine = getline('.')
        if (s:LineContent(getline(s:lineNumber)) ==# '' || <SID>IsList(getline(s:lineNumber)))
                \ && (s:LineContent(getline(s:lineNumber + 2)) ==# '' ||
                    \ <SID>IsList(getline(s:lineNumber + 2)))
            let l:thisLineLevel = <SID>FindLevel(l:thisLine)
            let l:prefix = repeat(s:IndentText(), l:thisLineLevel) . '1. '
            call setline('.', l:prefix . <SID>LineContent(l:thisLine))
            call setpos('.', [s:bufferNumber, s:lineNumber + 1,
                    \ s:cursorColumn + 3, s:cursorOffset])
        else
            echohl WarningMsg
            echom 'Cannot convert to list unless surrounded by bank lines.'
            echohl None
        endif
        call listmode#ReformatList()
        return
    endif
    if s:currentListType ==# 'dl'
        echohl WarningMsg
        echo 'Cannot change list type of description lists.'
        echohl None
        return
    endif
    let l:newType = a:listRotation[s:currentListType]
    let l:prefix = repeat(s:IndentText(), s:currentLineLevel) . l:newType
    let l:newCursorColumn = <SID>PlaceCursor(s:line, l:prefix, s:cursorColumn)
    let l:newLine = l:prefix . <SID>LineContent(s:line)
    if s:lineNumber > s:listBeginLineNumber  " ... need to search backwards to change list type
        for l:index in range(s:lineNumber - 1, s:listBeginLineNumber, -1)
            let l:thisLine = s:bufferText[l:index]
            let l:thisLineLevel = <SID>FindLevel(l:thisLine)
            if <SID>IsWhiteSpace(l:thisLine)
            elseif l:thisLineLevel < s:currentLineLevel
                break
            elseif l:thisLineLevel == s:currentLineLevel &&
                    \ <SID>FindListType(l:thisLine) ==# 'ls'
                break
            elseif l:thisLineLevel == s:currentLineLevel
                call setline(l:index + 1, l:prefix . <SID>LineContent(l:thisLine))
            endif
        endfor
    endif
    if s:lineNumber < s:listEndLineNumber  " ... we need to search forwards to change list type
        for l:index in range(s:lineNumber + 1, s:listEndLineNumber)
            let l:thisLine = s:bufferText[l:index]
            let l:thisLineLevel = <SID>FindLevel(l:thisLine)
            if <SID>IsWhiteSpace(l:thisLine)
            elseif l:thisLineLevel < s:currentLineLevel
                break
            elseif l:thisLineLevel == s:currentLineLevel && <SID>FindListType(l:thisLine) ==# 'ls'
                break
            elseif l:thisLineLevel == s:currentLineLevel
                call setline(l:index + 1, l:prefix . <SID>LineContent(l:thisLine))
            endif
        endfor
    endif
    call setline(s:lineNumber + 1, l:newLine)
    call setpos('.', [s:bufferNumber, s:lineNumber + 1, l:newCursorColumn, s:cursorOffset])
    call listmode#ReformatList()
endfunction

function! listmode#ChangeListTypeForward() abort  "{{{1
    let l:listRotation = g:ListMode_list_rotation_forward
    call <SID>ChangeListType(l:listRotation)
endfunction

function! listmode#ChangeListTypeBackward() abort  "{{{1
    let l:listRotation = g:ListMode_list_rotation_backward
    call <SID>ChangeListType(l:listRotation)
endfunction

function! listmode#NewListItem() abort  "{{{1
    " Add new list item above or below current line (depending on whether the
    " cursor is before or after the start of the line content).
    call <SID>InitializeListFunctions()
    if s:listEndLineNumber == 0
        let s:currentListType = 'nolist'
        let s:currentListNumbering = 0
    endif
    if mode() ==# 'n'
        let s:cursorColumn -= 1  " Needed adjustment for normal mode.
    endif
    let l:lineContent = <SID>LineContent(s:line)
    if s:currentListType ==# 'empty'
        if s:line ==# ''
            " If the current line really is empty (rather than whitespace),
            " need to add new line below with arbitrary list type. (This will
            " be fixed when calling listmode#ReformatList().)
            let l:newLineType = 'ul'
            for l:lineIndex in range(s:lineNumber - 1, s:listBeginLineNumber, -1)
                let l:thisLine = s:bufferText[l:lineIndex]
                if <SID>FindLevel(l:thisLine) == 0 &&
                        \ index(['ol', 'ul', 'nl', 'el'], <SID>FindListType(l:thisLine)) >= 0
                    let l:newLineType = <SID>FindListType(l:thisLine)
                    break
                endif
            endfor
            let l:newLine = s:listDef[l:newLineType]
            let l:newCursorColumn = len(l:newLine)
            call append(s:lineNumber + 1, l:newLine)
            call setpos('.', [s:bufferNumber, s:lineNumber + 2,
                        \ l:newCursorColumn, s:cursorOffset])
            call listmode#ReformatList()
            return
        else
            " Current line is only whitespace, so outdent.
            call listmode#OutdentLine()
            return
        endif
    elseif <SID>IsWhiteSpace(l:lineContent) && s:currentListType !=# 'nolist'
        if s:currentLineLevel > 0
            " If indented, need to outdent.
            call listmode#OutdentLine()
            return
        else
            " If not indented but has list prefix, delete that prefix and
            " relocate cursor.
            call setline(s:lineNumber + 1, '')
            call setpos('.', [s:bufferNumber, s:lineNumber + 1, 0, s:cursorOffset])
            call listmode#ReformatList()
            return
        endif
    endif
    let l:linePrefixLength = len(s:line) - len(l:lineContent)
    let l:prefix = repeat(s:IndentText(), s:currentLineLevel)
            \ . s:listDef[s:currentListType]
    if (s:currentListType ==# 'nolist' && len(s:line) == 0) ||
            \ l:linePrefixLength <= s:cursorColumn - 1
        " If cursor is placed after start of line content: need to create new
        " line below ... unless we're not in a list.
        let l:newLine = s:line[:s:cursorColumn - 1]
        let l:nextLine = l:prefix . s:line[s:cursorColumn :]
        let l:newLineNumber = s:lineNumber + 1
        let l:newCursorColumn = len(l:prefix)
    else
        " Cursor is placed before start of line content: need to create new
        " line above
        let l:nextLine = s:line
        let l:newLine = l:prefix
        let l:newLineNumber = s:lineNumber
        let l:newCursorColumn = len(l:prefix)
    endif
    call setline(s:lineNumber + 1, l:newLine)
    call append(s:lineNumber + 1, l:nextLine)
    call setpos('.', [s:bufferNumber, l:newLineNumber + 1,
            \ l:newCursorColumn + 1, s:cursorOffset])
    call listmode#ReformatList()
endfunction
" }}}
function! listmode#GoToStartOfListItem() abort  "{{{1
    let l:thisLine = getline('.')
    if empty(l:thisLine) || !<SID>IsList(l:thisLine)
        normal! _
        return
    endif
    let [l:a, l:b, l:c, l:d] = getpos('.')
    " Find position of first character of list text
    let l:startPosition = match(l:thisLine,
            \ '\(^\s*\((\?[0-9#]\+[.)]\|(\?@[A-z0-9\-_]*[.)]\|[-*+:]\)\s\+\)\@<=\S') + 1
    if l:startPosition == 0 || l:c == l:startPosition
        " if we're not in a list, or we're already at start of list, go to
        " first non-blank character in line
        normal! _
    else
        call setpos('.', [l:a, l:b, l:startPosition, l:d, l:startPosition])
    endif
endfunction
"}}}

" =============================================================================
" Functions defining list text object
" =============================================================================

function! s:CurrentListItem(matchPattern) abort  "{{{1
    let l:thisLine = getline('.')
    if empty(l:thisLine)
        return 0
    endif
    let l:startPosition = match(l:thisLine, a:matchPattern)
    if l:startPosition == -1
        echohl WarningMsg
        echo 'Not a list item!'
        echohl None
        return 0
    else
        let [l:a, l:b, l:c, l:d] = getpos('.')
        let l:endPosition = col('$') - 1
        return ['v', [l:a, l:b, l:startPosition + 1, l:d],
                \ [l:a, l:b, l:endPosition, l:d]]
    endif
endfunction

function! listmode#CurrentListItemA() abort "{{{1
    return <SID>CurrentListItem('\(^\s*\)\@<=\((\?[0-9#]\+[.)]\|(\?@[A-z0-9\-_]*[.)]\|[-*+:]\)\s\+')
endfunction

function! listmode#CurrentListItemI() abort "{{{1
    return <SID>CurrentListItem('\(^\s*\((\?[0-9#]\+[.)]\|(\?@[A-z0-9\-_]*[.)]\|[-*+:]\)\s\+\)\@<=\S')
endfunction

function! s:CurrentListTree(type) abort  "{{{1
    let l:thisLine = getline('.')
    if empty(l:thisLine)
        return 0
    endif
    let [l:a, l:b, l:c, l:d] = getpos('.')
    let l:indentLevel = <SID>FindLevel(l:thisLine)
    if <SID>IsList(l:thisLine) || <SID>FindLevel(l:thisLine) > 0
        if a:type ==# 'a'  " Around list tree -- so search backwards
            for l:startLine in range(l:b, 1, -1)
                let l:tempLine = getline(l:startLine)
                " echom l:startLine . ':' . <SID>IsList(l:tempLine) . '|' . <SID>IsWhiteSpace(l:tempLine)
                if <SID>FindLevel(l:tempLine) < l:indentLevel &&
                        \ !s:IsWhiteSpace(l:tempLine)
                    break
                elseif l:indentLevel == 0 && (s:FindLevel(l:tempLine) == 0 &&
                        \ !s:IsList(l:tempLine) && !s:IsWhiteSpace(l:tempLine))
                    let l:startLine += 1
                    break
                endif
            endfor
        else  " Inside list tree -- so search from here down
            let l:startLine = l:b
            let l:indentLevel += 1
        endif
        while <SID>IsWhiteSpace(getline(l:startLine))
            let l:startLine += 1
        endwhile
        " echom l:startLine
        let l:endLine = line('$')
        for l:endLine in range(l:b + 1, line('$'))
            let l:tempLine = getline(l:endLine)
            " echom l:endLine . ':' . <SID>IsList(l:tempLine) . '|' . <SID>IsWhiteSpace(l:tempLine)
            if <SID>FindLevel(getline(l:endLine)) < l:indentLevel &&
                    \ !s:IsWhiteSpace(getline(l:endLine))
                let l:endLine -= 1
                break
            elseif l:indentLevel == 0 && (s:FindLevel(l:tempLine) == 0 &&
                    \ !s:IsList(l:tempLine) && !s:IsWhiteSpace(l:tempLine))
                let l:endLine -= 1
                break
            endif
        endfor
        " echom l:endLine
        return ['V', [l:a, l:startLine, 0, 0], [l:a, l:endLine, 0, 0]]
    else
        echohl WarningMsg
        echo 'Not a list item!'
        echohl None
        return 0
    endif
endfunction

function! listmode#CurrentListTreeI() abort  "{{{1
    return <SID>CurrentListTree('i')
endfunction

function! listmode#CurrentListTreeA() abort  "{{{1
    return <SID>CurrentListTree('a')
endfunction
" }}}

" =============================================================================
" Folding code. Adapted from:
" <http://learnvimscriptthehardway.stevelosh.com/chapters/49.html>
" =============================================================================

function! s:NextNonBlankLine(lnum) abort  "{{{1
    " Find line number of next non-blank line
    let l:current = a:lnum + 1
    while l:current <= line('$')
        if !s:IsWhiteSpace(getline(l:current))
            return l:current
        endif
        let l:current += 1
    endwhile
    return -2
endfunction

function! listmode#GetListModeFold(lnum) abort  "{{{1
    " Find fold level of line at given line number
    let l:thisLine = getline(a:lnum)
    if <SID>IsWhiteSpace(l:thisLine)
        return '-1'
    endif
    if !empty(s:FindListType(l:thisLine)) || <SID>FindLevel(l:thisLine) > 0
        let l:thisIndent = <SID>FindLevel(l:thisLine) + 1
        let l:nextIndent = <SID>FindLevel(getline(s:NextNonBlankLine(a:lnum))) + 1
        
        if l:nextIndent <= l:thisIndent
            return l:thisIndent
        else  "  l:nextIndent > l:thisIndent
            return '>' . l:nextIndent
        endif
    endif
    return 0
endfunction

function! listmode#FoldText() abort  "{{{1
    " Provide text for line when folded
    let l:foldLineCount = v:foldend - v:foldstart
    return v:folddashes . getline(v:foldstart)[:max([0, winwidth(0) - 24])]
            \ . ' / ' . l:foldLineCount . ' sub-items / '
endfunction
