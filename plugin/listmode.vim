" vim: set fdm=marker et ts=4 sw=4 sts=4:
" listmode.vim - Vim: List mode for pandoc version of markdown
" Author:        bwhelm
" Version:       0.1

if exists('g:ListMode_loaded')
    finish
endif

let g:ListMode_loaded = 1

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

execute "noremap" g:vim_listmode_toggle ":call ToggleListMode()<CR>"
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

function! IsUOList(line) " {{{1
    " Check if line is unordered or ordered list
	return match(a:line, '^\s*\([0-9#]\+\.\|@[A-z0-9\-_]*\.\|[-*+]\)\s') >= 0
endfunction

function! IsUList(line) " {{{1
    " Check if line is unordered list
	return match(a:line, '^\s*[-*+]\s') >= 0
endfunction

function! IsOList(line) " {{{1
    " Check if line is ordered list
	return match(a:line, '^\s*[0-9]\+\.\s') >= 0
endfunction

function! IsSpecialListOne(line) " {{{1
    " Check if line is special list 1
	return match(a:line, '^\s*#\+\.\s') >= 0
endfunction

function! IsSpecialListTwo(line) " {{{1
    " Check if line is special list 2
	return match(a:line, '^\s*@[A-z0-9\-_]*\.\s') >= 0
endfunction

function! IsDescList(lines) " {{{1
    " Check if lines (list of single lines) contains a description list
	let l:text = join(a:lines, "\n")
	return match(l:text, '^\s*\S.*\n\s*[:~]\s\+\S') >= 0
endfunction

function! IsWhiteSpace(line) " {{{1
    " Check if line contains only whitespace
	return match(a:line, '^\s*$') >= 0
endfunction

function! FindLevel(line) " {{{1
    " Find indentation level of line
	let l:nonSpaceIndex = match(a:line, '\S')
	let l:initialSpaces = a:line[:l:nonSpaceIndex]
	let l:initialSpaces = substitute(l:initialSpaces, "\t", '    ', 'g')
	return len(l:initialSpaces) / 4
endfunction

function! FindListType(line) " {{{1
    " Find type of list of current line. ('ol' = ordered list; 'ul' = unordered
    " list; 'sl1' = special list #1; 'sl2' = special list #2; 'dl' = description
    " list.
	if IsWhiteSpace(a:line)
		return 'empty'
	elseif IsOList(a:line)
		return 'ol'
	elseif IsUList(a:line)
		return 'ul'
	elseif IsSpecialListOne(a:line)
		return 'sl1'
	elseif IsSpecialListTwo(a:line)
		return 'sl2'
	elseif match(a:line, '^\s*[~:]\s') >= 0
		return 'dl'
	else
		return 0  " If we know it's a list item, this will be a 'dl'
	endif
endfunction

function! LineContent(line) " {{{1
    " Return content of line, stripped of any white space and list indicators at
    " the beginning of the line.
	if index(['ol','ul','sl1','sl2','empty'], FindListType(a:line)) >= 0
		let l:lineStart = match(a:line, '\(^\s*\([0-9#]\+\.\|@[A-z0-9\-_]*\.\|[-*+]\)\s\+\)\@<=.*')
		return a:line[l:lineStart:]
	else  " Must be description list or nolist
		let l:lineStart = match(a:line, '\S')
        if l:lineStart == -1
            return ""
        else
            return a:line[l:lineStart:]
        endif
	endif
endfunction

function! FindListScope() " {{{1
    " Find set of lines around cursor that is a list
    let l:lineNumber = s:lineNumber
	let l:listType = FindListType(s:bufferText[l:lineNumber])
	let l:begin = 0  " Catches case when cursor starts at beginning of file, which is also beginning of list
	let l:end = len(s:bufferText) - 1  " Catches case in which cursor starts at end of file, which is also end of list
	if empty(l:listType) || l:listType == 'dl'
		if IsDescList(s:bufferText[l:lineNumber - 1:l:lineNumber + 2])
			let l:listType = 'dl'
		else
			let l:listType = 0
		endif
	endif
	if !empty(l:listType)  " If current line is empty or a list line...
		if l:listType == 'dl' && match(s:bufferText[l:lineNumber], '^\s*[:~]\s') >= 0  " second line of DL
			let l:lineNumber -= 1  " Go back one line to start of DL
		endif
		" Search backwards
		let l:lineIndex = l:lineNumber
		" l:listStructure is a dictionary of lists: {lineno: [listType, listLevel]}
		let l:listStructure = {}
		while lineIndex >= 0
			let l:listType = FindListType(s:bufferText[l:lineIndex])
			if !empty(l:listType) && l:listType != "dl"
				let l:listStructure[l:lineIndex] = [l:listType, FindLevel(s:bufferText[l:lineIndex])]
				let l:lineIndex -= 1
			elseif IsDescList(s:bufferText[max([0, l:lineIndex - 1]):l:lineIndex + 2 + (l:lineIndex == -1)])
				let l:listStructure[l:lineIndex - 1] = ['dl', FindLevel(s:bufferText[l:lineIndex])]
				let l:listStructure[l:lineIndex] = ['dl', FindLevel(s:bufferText[l:lineIndex])]
				" TODO: Need to check for more than one definition in DL
				let l:lineIndex -= 2
			else
				let l:begin = max([lineIndex + 1, 0])
				break
			endif
		endwhile
		" Search forwards
		let l:lineIndex = l:lineNumber + 1
		while l:lineIndex < len(s:bufferText)
			let l:listType = FindListType(s:bufferText[l:lineIndex])
			if !empty(l:listType)
				let l:listStructure[l:lineIndex] = [l:listType, FindLevel(s:bufferText[l:lineIndex])]
				let l:lineIndex += 1
			elseif IsDescList(s:bufferText[max([0, l:lineIndex - 1]):l:lineIndex + 2 + (l:lineIndex == -1)])
				let l:listStructure[l:lineIndex] = ['dl', FindLevel(s:bufferText[l:lineIndex])]
				let l:listStructure[l:lineIndex + 1] = ['dl', FindLevel(s:bufferText[l:lineIndex])]
				" TODO: Need to check for more than one definition in DL
				let l:lineIndex += 2
			else
				let l:end = lineIndex - 1
				break
			endif
		endwhile
		" Edge case: Don't consider it a list if current line is empty and at
		" the beginning of the list.
		if IsWhiteSpace(s:bufferText[l:lineNumber]) && l:lineNumber == l:begin
			return [0, 0, []]
		endif
		" Edge case: Don't consider a list if l:begin == l:end
		if l:begin == l:end
			return [0, 0, []]
		endif
		" Edge case: Don't consider series of blank lines a list.
		let l:realList = 0
		for l:line in s:bufferText[l:begin:l:end]
			if !IsWhiteSpace(l:line)
				let l:realList = 1
				break
			endif
		endfor
		if l:realList
			return [l:begin, min([end, len(s:bufferText) - 1]), l:listStructure]
		else
			return [0, 0, []]
		endif
	else
		return [0, 0, []]
	endif
endfunction

function! PlaceCursor(line, prefix, column) " {{{1
    " PlaceCursor() will take a line, a prefix to be added to that line's content,
    " and a cursor position of the original line, and calculate a new cursor
    " position with the prefix added.
	let l:lineContent = LineContent(a:line)
	let l:linePrefixLength = len(a:line) - len(l:lineContent)
	if l:linePrefixLength < a:column  " If cursor is placed after start of line content
		let l:cursorColumn = len(a:prefix) - l:linePrefixLength + a:column
	else
		let l:cursorColumn = len(a:prefix) + 1
	endif
	return l:cursorColumn
endfunction

function! InitializeListFunctions() "{{{1
    " Set variables for common list functions
	let s:bufferText = getline(0,"$")
	let [s:bufferNumber, s:lineNumber, s:cursorColumn, s:cursorOffset] = getpos('.')
	let s:lineNumber -= 1
	let s:line = s:bufferText[s:lineNumber]
    let s:currentLineLevel = FindLevel(s:line)
	let [s:listBeginLineNumber, s:listEndLineNumber, s:listStructure] = FindListScope()
    if s:listEndLineNumber != 0  " Currently in a list...
        let [s:currentListType, s:currentListNumbering] = s:listStructure[s:lineNumber]
    else  " Not in a list...
        let s:currentListType = 'nolist'
        let s:currentListNumbering = 0
    endif
    " To convert from listType to the needed (pandoc) markdown
    let s:listDef = {'ol': '1. ', 'ul': '- ', 'sl1': '#. ', 'sl2': '@', 'empty': '', 'dl': '', 'nolist': ''} 
endfunction

function! ReformatList() " {{{1
    " Finds list surrounding current cursor location and reformats it
    call InitializeListFunctions()
	if s:listEndLineNumber == 0  " Not in a list!
		return
	endif
	" l:levelRecord is a list of ordered pairs: ('list type', number), where 
	" number designates the current count for ordered lists.
	let l:levelRecord = []
	" Initialize 20 levels of emptiness in levelRecord
	for i in range(20)
		let l:levelRecord += [['empty', 0]]
	endfor
	let l:previousLevel = -1
	let l:newList = []
    let l:newCursorColumn = s:cursorColumn
	for l:key in range(s:listBeginLineNumber, s:listEndLineNumber)
		let [l:listType, l:listLevel] = s:listStructure[key]
		" If l:listType == 'empty', I want to leave it alone, so that gets
		" skipped in next conditional.
		if index(['ul', 'ol', 'sp1', 'sp2', 'dl'], l:listType) >= 0
			let [l:LRType, l:LRNumber] = l:levelRecord[l:listLevel]
			if l:listLevel > l:previousLevel  " Beginning of sublist
				if l:listType == 'ol'
					let l:levelRecord[l:listLevel] = ['ol', 1]
				else
					let l:levelRecord[l:listLevel] = [l:listType, 0]
				endif
			elseif l:listLevel == l:previousLevel  " List sibling
				if l:LRType == 'ol'
					let l:levelRecord[l:listLevel] = ['ol', l:LRNumber + 1]
				endif
			elseif l:listLevel < l:previousLevel  " List parent
				if l:LRType == 'empty'
					if l:listType == 'ol'
						let l:levelRecord[l:listLevel] = ['ol', 1]
					else
						let l:levelRecord[l:listLevel] = [l:listType, 0]
					endif
				else
					if l:LRType == 'ol'
						let l:levelRecord[l:listLevel] = ['ol', l:LRNumber + 1]
					endif
				endif
			endif
			" Now need to construct list item
			let [l:LRType, l:LRNumber] = l:levelRecord[l:listLevel]
			let l:itemText = LineContent(s:bufferText[l:key])
			let l:newItemPrefix = repeat("\t", l:listLevel)
			if l:LRType == 'ol'
				let l:newItemPrefix .= l:LRNumber . '. '
			else
				let l:newItemPrefix .= s:listDef[l:LRType]
			endif
			let l:newLine = l:newItemPrefix . l:itemText
			if l:key == s:lineNumber
				let l:newCursorColumn = PlaceCursor(s:bufferText[l:key], l:newItemPrefix, s:cursorColumn)
			endif
			call setline(l:key + 1, l:newLine)
			let l:previousLevel = l:listLevel
		endif
	endfor
	call setpos('.', [s:bufferNumber, s:lineNumber + 1, l:newCursorColumn, s:cursorOffset])
endfunction

function! IndentLine() " {{{1
    " Indent current line, changing list type of lines as appropriate
    call InitializeListFunctions()
	if LineContent(s:line)[0] == ":" && s:line[s:cursorColumn - 2] == ":"
		" We're at beginning of description list, which contains only a ':'
		" character, so a <tab> should be interpreted as a <tab> rather than
		" indenting the line.
		let l:newLine = s:line[:s:cursorColumn - 1] . "\t" . s:line[s:cursorColumn:]
		let l:newCursorColumn = s:cursorColumn + 1
	elseif s:currentListType == 'dl'
		echo "Cannot indent description lists. Hit '>>'."
		return
	else
		let l:prefix = repeat("\t", FindLevel(s:line) + 1)
		if s:currentListType == 'sl2'
			let l:prefix .= '@. '
		else
			let l:prefix .= s:listDef[s:currentListType]
		endif
        let l:newLine = l:prefix
        if match(s:line, '\S') >= 0
            let l:newLine .= LineContent(s:line)
        endif
		let l:newCursorColumn = PlaceCursor(s:line, l:prefix, s:cursorColumn)
	endif
	call setline(s:lineNumber + 1, l:newLine)
	call setpos('.', [s:bufferNumber, s:lineNumber + 1, l:newCursorColumn, s:cursorOffset])
	call ReformatList()
endfunction

function! OutdentLine() " {{{1
    " Outdent current line, changing list type of lines as appropriate
    call InitializeListFunctions()
	if s:currentListType == 'dl'
		echo "Cannot outdent description lists. Hit '<<'."
		return
	elseif s:currentLineLevel > 0  " We need to outdent
		let l:prefix = repeat("\t", FindLevel(s:line) - 1)
		let l:prefix .= s:listDef[s:currentListType]
        let l:newLine = l:prefix
        if match(s:line, '\S') >= 0
            let l:newLine .= LineContent(s:line)
        endif
		let l:newCursorColumn = PlaceCursor(s:line, l:prefix, s:cursorColumn)
	else
		echo "Cannot outdent any further!"
        return
	endif
	call setline(s:lineNumber + 1, l:newLine)
	call setpos('.', [s:bufferNumber, s:lineNumber + 1, l:newCursorColumn, s:cursorOffset])
	call ReformatList()
endfunction

function! ChangeListType() " {{{1
    " ChangeListType() will search backwards and forwards in theList to find all
    " siblings of the current line and will change them to a given list type.
    "
	" l:listRotation specifies how list types rotate: ordered lists become unordered lists; everything else becomes an ordered list.	
    call InitializeListFunctions()
	let l:listRotation = {'ol': '- ', 'ul': '1. ', 'sl2': '1. ', 'sl1': '1. ', 'empty': '1. ', 'dl': '1. '}
	if s:listEndLineNumber == 0
		echo "Not in a list so cannot change list type!"
		return
	endif
	if s:currentListType == 'dl'
		echo "Cannot change list type of description lists."
		return
	endif
	let l:newType = l:listRotation[s:currentListType]
	let l:prefix = repeat("\t", s:currentLineLevel) . l:newType
	let l:newCursorColumn = PlaceCursor(s:line, l:prefix, s:cursorColumn)
	let l:newLine = l:prefix . LineContent(s:line)
	if s:lineNumber > s:listBeginLineNumber  " ... we need to search backwards to change list type
		for l:index in range(s:lineNumber - 1, s:listBeginLineNumber, -1)
			let l:thisLine = s:bufferText[l:index]
			let l:thisLineLevel = FindLevel(l:thisLine)
			if IsWhiteSpace(l:thisLine)
			elseif l:thisLineLevel < s:currentLineLevel
				break
			elseif l:thisLineLevel == s:currentLineLevel
				call setline(l:index + 1, l:prefix . LineContent(l:thisLine))
			endif
		endfor
	endif
	if s:lineNumber < s:listEndLineNumber  " ... we need to search forwards to change list type
		for l:index in range(s:lineNumber + 1, s:listEndLineNumber)
			let l:thisLine = s:bufferText[l:index]
			let l:thisLineLevel = FindLevel(l:thisLine)
			if IsWhiteSpace(l:thisLine)
			elseif l:thisLineLevel < s:currentLineLevel
				break
			elseif l:thisLineLevel == s:currentLineLevel
				call setline(l:index + 1, l:prefix . LineContent(l:thisLine))
			endif
		endfor
	endif
	call setline(s:lineNumber + 1, l:newLine)
	call setpos('.', [s:bufferNumber, s:lineNumber + 1, l:newCursorColumn, s:cursorOffset])
	call ReformatList()
endfunction

function! NewListItem() " {{{1
    " Add new list item above or below current line (depending on whether the
    " cursor is before or after the start of the line content).
    call InitializeListFunctions()
	if s:listEndLineNumber == 0
        let s:currentListType = "nolist"
        let s:currentListNumbering = 0
	endif
    if mode() == 'n'
        let s:cursorColumn -= 1  " Needed adjustment for normal mode.
    endif
    let l:lineContent = LineContent(s:line)
	if s:currentListType == "empty"
        " If the current line really is empty (rather than whitespace), need
        " to add new line below with 
        if s:line == ""
            let l:newLineType = 'ul'
            for l:lineIndex in range(s:lineNumber - 1, s:listBeginLineNumber, -1)
                let l:thisLine = s:bufferText[l:lineIndex]
                if FindLevel(l:thisLine) == 0 && index(['ol', 'ul', 'sl1', 'sl2'], FindListType(l:thisLine)) >= 0
                    let l:newLineType = FindListType(l:thisLine)
                    break
                endif
            endfor
            let l:newLine = s:listDef[l:newLineType]
            let l:newCursorColumn = len(l:newLine)
            call append(s:lineNumber + 1, l:newLine)
            call setpos('.', [s:bufferNumber, s:lineNumber + 2, l:newCursorColumn, s:cursorOffset])
            call ReformatList()
            return
        else
            call append(s:lineNumber + 1, s:line)
            call setpos('.', [s:bufferNumber, s:lineNumber + 2, s:cursorColumn, s:cursorOffset])
            call ReformatList()
            return
        endif
    elseif IsWhiteSpace(l:lineContent) && s:currentListType != "nolist"
        if s:currentLineLevel > 0
            call OutdentLine()
            return
        else
            call setline(s:lineNumber + 1, "")
            call setpos('.', [s:bufferNumber, s:lineNumber + 1, 0, s:cursorOffset])
            call ReformatList()
            return
        endif
    endif
    let l:linePrefixLength = len(s:line) - len(l:lineContent)
    let l:prefix = repeat("\t", s:currentLineLevel) . s:listDef[s:currentListType]
    if s:currentListType == "nolist" || l:linePrefixLength < s:cursorColumn - 1
        " If cursor is placed after start of line content: need to create new line below
        " ... unless we're not in a list.
        let l:beforeCursor = LineContent(s:line[:s:cursorColumn - 1])
        let l:afterCursor = s:line[s:cursorColumn:]
        let l:newLine = l:prefix . l:beforeCursor
        let l:nextLine = l:prefix . l:afterCursor
        let l:newLineNumber = s:lineNumber + 1
        let l:newCursorColumn = len(l:prefix)
    else  " Cursor is placed before start of line content: need to create new line above
        let l:nextLine = s:line
        let l:newLine = l:prefix
        let l:newLineNumber = s:lineNumber
        let l:newCursorColumn = len(l:prefix)
    endif
	call setline(s:lineNumber + 1, l:newLine)
    call append(s:lineNumber + 1, l:nextLine)
	call setpos('.', [s:bufferNumber, l:newLineNumber + 1, l:newCursorColumn + 1, s:cursorOffset])
	call ReformatList()
endfunction
" }}}


" Restores mapping saved in mapDict {{{1
function! RestoreMapping(mapDict, key, mode)
	exe a:mode . 'unmap <buffer> ' . a:key
	if !empty(a:mapDict)
		exe (a:mapDict.noremap ? a:mapDict.mode . 'noremap' : a:mapDict.mode .'map') .
			\ (a:mapDict.buffer ? ' <buffer>' : '') .
			\ (a:mapDict.expr ? ' <expr>' : '') .
			\ (a:mapDict.nowait ? ' <nowait>' : '') .
			\ (a:mapDict.silent ? ' <silent>' : '') .
			\ ' ' . a:mapDict.lhs .
			\ ' ' . a:mapDict.rhs
	endif
endfunction

" Switches between mappings {{{1
function! ToggleListMode()
    if !exists('b:listmode')
        let b:listmode = 0  " Start with listmode off by default with new buffer
    endif
	if b:listmode		" Need to swap keymappings back
		call RestoreMapping(b:listmode_indent_normal, '<Tab>', 'n')
		call RestoreMapping(b:listmode_indent_insert, '<Tab>', 'i')
		call RestoreMapping(b:listmode_outdent_normal, '<S-Tab>', 'n')
		call RestoreMapping(b:listmode_outdent_insert, '<S-Tab>', 'i')
		call RestoreMapping(b:listmode_newitem_normal, '<CR>', 'n')
		call RestoreMapping(b:listmode_newitem_insert, '<CR>', 'i')
		call RestoreMapping(b:listmode_changetype_normal, '<D-8>', 'n')
		call RestoreMapping(b:listmode_changetype_insert, '<D-8>', 'i')
		let b:listmode=0
		echo "Now leaving vim list mode"
	else				" Need to save keymappings and generate new ones
		let b:listmode_indent_normal = maparg("<Tab>", "n", 0, 1)
		let b:listmode_indent_insert = maparg("<Tab>", "i", 0, 1)
		let b:listmode_outdent_normal = maparg("<S-Tab>", "n", 0, 1)
		let b:listmode_outdent_insert = maparg("<S-Tab>", "i", 0, 1)
		let b:listmode_newitem_normal = maparg("<CR>", "n", 0, 1)
		let b:listmode_newitem_insert = maparg("<CR>", "i", 0, 1)
		let b:listmode_changetype_normal = maparg("<D-8>", "n", 0, 1)
		let b:listmode_changetype_insert = maparg("<D-8>", "i", 0, 1)
		execute "nnoremap <buffer> <silent>" g:ListMode_indent_normal ":call IndentLine()<CR>"
		execute "inoremap <buffer> <silent>" g:ListMode_indent_insert "<C-o>:call IndentLine()<CR>"
		execute "nnoremap <buffer> <silent>" g:ListMode_outdent_normal ":call OutdentLine()<CR>"
		execute "inoremap <buffer> <silent>" g:ListMode_outdent_insert "<C-o>:call OutdentLine()<CR>"
		execute "nnoremap <buffer> <silent>" g:ListMode_newitem_normal ":call NewListItem()<CR>"
		execute "inoremap <buffer> <silent>" g:ListMode_newitem_insert "<C-o>:call NewListItem()<CR>"
		execute "nnoremap <buffer> <silent>" g:ListMode_changetype_normal ":call ChangeListType()<CR>"
		execute "inoremap <buffer> <silent>" g:ListMode_changetype_insert "<C-o>:call ChangeListType()<CR>"
		let b:listmode = 1
		echo "Now entering vim list mode"
	endif
endfunction

