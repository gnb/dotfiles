"
" VIM Patch mode
"
" By Greg Banks <greg.n.banks@gmail.com> 2008/09/12
"
function s:SaveCursor()
    let s:curs_line = line(".")
    let s:curs_col = col(".")
endfunction

function s:RestoreCursor()
    call cursor(s:curs_line, s:curs_col)
endfunction

function s:HunkStart()
    let lno = line(".")
    while lno >= 1
	let ll = getline(lno)
	if ll =~ '^@@ '
	    return lno
	endif
	if ll !~ '^[-+ ]'
	    return -1
	endif
	let lno = lno - 1
    endwhile
    return -1
endfunction

function s:HunkEnd()
    let lno = line(".")
    let last = line("$")
    while lno < last
	let ll = getline(lno+1)
	if ll !~ '^[-+ ]'
	    return lno
	endif
	let lno = lno + 1
    endwhile
    return lno
endfunction

function s:FileStart()
    let lno = line(".")
    let next_is_hunk = 0
    while lno >= 1
	let ll = getline(lno)
	if ll =~ '^@@ '
	    let next_is_hunk = 1
	elseif ll =~ '^+++ ' && next_is_hunk == 1
	    return lno
	elseif ll !~ '^[-+ ]'
	    return -1
	else
	    let next_is_hunk = 0
	endif
	let lno = lno - 1
    endwhile
    return -1
endfunction

function PatchNormaliseHunk()
    call s:SaveCursor()
    let start = s:HunkStart()
    let end = s:HunkEnd()
    if end < 0 || start < 0
	return
    endif
    let cmd = ":" . start . "," . end . "!patch-normalise-hunk.pl"
    execute cmd
    call s:RestoreCursor()
endfunction

" set buftype=nofile
" OR MAYBE set buftype=quickfix
" set bufhidden=hide
" set noswapfile
" set nobuflisted
" function PatchTryApply()
"     let cmd = ":1,$"
"     execute cmd
" endfunction

" function PatchAddCommands()
"     if !exists(":try")
" 	command try :call PatchTryApply()
"     endif
" endfunction

function PatchSignoff()
    execute ":1,$!patch-signoff.pl"
endfunction

function PatchEditFile()
    " Find the previous file header in the patch
    let start = s:FileStart()
    if start < 0
	return
    endif
    " Extract the name of a readable file from the file header
    let file = matchstr(getline(start), '[^ \t]\+', 4)
    while file != "" && !filereadable(file)
	echo ">> file=\"" . file . "\""
	let ii = matchend(file, '/\+')
	if ii < 0
	    return
	endif
	let file = strpart(file, ii)
    endwhile
    " At this point 'file' is the filename of a readable file
    " Find the previous hunk header in the patch
    let here = line(".")
    let start = s:HunkStart()
    if start < 0
	return
    endif
    " Extract a line number from the hunk header
    let line = matchstr(getline(start), '[0-9]\+', 4)
    " Open a new buffer with the file and seek to the line
    execute ":new " . file
    execute ":" . (line + (here - start - 1))
endfunction

function PatchSelectHunk()
    let start = s:HunkStart()
    let end = s:HunkEnd()
    if end < 0 || start < 0
	return
    endif
    execute ":" . start
    normal V
    execute "normal " . (end-start) . "j"
endfunction

function PatchLinesIdentical()
    let lno = line(".")
    let thisline = getline(lno)
    let nextline = getline(lno+1)

    if strpart(thisline,0,1) != "-"
	return
    endif
    if strpart(nextline,0,1) != "+"
	return
    endif
    if strpart(thisline,1) != strpart(nextline,1)
	return
    endif
    normal dd
    normal 0
    normal r 
endfunction

function PatchTryApply()
    let patchfname = expand("%:p")
    let patchlines = getline(1,"$")
    let output = system("patch -p1 -f --dry-run 2>&1", join(patchlines, "\n") . "\n")

    " Scan the patch lines to find hunk boundaries
    " Build a dict which maps [file:hunknum] -> patch-line-num
    let hunks = {}
    let fname = ""
    let hnum = 0
    let lnum = 1
    for line in patchlines
	if line =~ '^+++ '
	    let fname = strpart(line, 5)
	    " Hardcoded to -p1
	    let fname = strpart(fname, stridx(fname, '/')+1)
	    let hnum = 1
	elseif line =~ '^@@ '
	    if fname != ""
		let hunks[fname . ":" . hnum] = lnum
		let hnum = hnum + 1
"		echo "XX F " . fname . " H " . hnum . " -> " . lnum
	    endif
	endif
	let lnum = lnum + 1
    endfor

    " Parse the output for hunk fail messages
    let reports = []
    let fname = ""
    for line in split(output, '\n')
"	let reports = reports + [ "> " . line ]
	if line =~ '^patching file '
	    let fname = strpart(line, 14)
"	    let reports = reports + [ "F " . fname ]
	elseif line =~ '^Hunk #[0-9]\+ succeeded at [0-9]\+ with fuzz'
	    let hnum = matchstr(line, '[0-9]\+')
	    let flnum = matchstr(line, '[0-9]\+', 12)
	    let msg = matchstr(line, 'fuzz[^.]*')
	    let fileloc = fname . ":" . flnum
	    let patchloc = patchfname . ":" . hunks[fname . ":" . hnum]
	    let reports += [ patchloc . ": Hunk " . msg . " at " . fileloc ]
	elseif line =~ '^Hunk #[0-9]\+ FAILED at [0-9]\+\.$'
	    let hnum = matchstr(line, '[0-9]\+')
	    let flnum = matchstr(line, '[0-9]\+', 12)
	    let fileloc = fname . ":" . flnum
	    let patchloc = patchfname . ":" . hunks[fname . ":" . hnum]
	    let reports += [ patchloc . ": Hunk FAILED at " . fileloc ]
	elseif line =~ '^patch:.*malformed patch at line [0-9]\+:'
	    let plnum = matchstr(line, '[0-9]\+')
	    let patchloc = patchfname . ":" . plnum
	    let reports += [ patchloc . ": malformed patch" ]
	endif
    endfor

    if reports == []
	echo "Patch will apply with no failures or fuzz"
    else
	" build a quickfix list on the current window; the user
	" can now cycle through the errors using commands like
	" :cn :cp :crewind and :clist
	cexpr reports
    endif
endfunction

function DetectQuiltPatches()
    let fname = expand("%:p")
    if (match(fname, "/patches/[^/]\\+$") >= 0 && match(fname, "/series$") < 0)
	execute "set filetype=diff\n"
    endif
endfunction
autocmd BufReadPre * call DetectQuiltPatches()

autocmd FileType diff map <buffer> <Esc>n :call PatchNormaliseHunk()<CR>
autocmd FileType diff map <buffer> <Esc>s :call PatchSignoff()<CR>
autocmd FileType diff map <buffer> <Esc>d :call PatchEditFile()<CR>
autocmd FileType diff map <buffer> <Esc>g :call PatchSelectHunk()<CR>
autocmd FileType diff map <buffer> <Esc>i :call PatchLinesIdentical()<CR>
autocmd FileType diff map <buffer> <Esc>a :call PatchTryApply()<CR>
" The tricks for highlighting bad whitespace need to be
" adjusted for diffs.
autocmd FileType diff highlight clear BadLeadingWS
autocmd FileType diff highlight clear TrailingWS
autocmd FileType diff highlight PatchInvalidLead ctermbg=red
autocmd FileType diff let m = matchadd("PatchInvalidLead", "^[^-+ @]")
autocmd FileType diff highlight PatchBadLeadingWS ctermbg=red
autocmd FileType diff let m = matchadd("PatchBadLeadingWS", "\\%2v[ \t]* \t[ \t]*")
autocmd FileType diff highlight PatchTrailingWS ctermbg=red
autocmd FileType diff let m = matchadd("PatchTrailingWS", "\\%>1v[ \t]\\+$")
" autocmd FileType diff call PatchAddCommands()
