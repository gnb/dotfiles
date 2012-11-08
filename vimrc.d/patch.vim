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

function s:HunkFile()
    " Find the previous file header in the patch
    let start = s:FileStart()
    if start < 0
	return null
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
    return file
endfunction

" Return a list describing the shape of the hunk from the hunk header
" First 2 elements are line number and length in the old file;
" next 2 elements are line number and length in the new file.
function s:HunkShape()
    " Find the previous hunk header in the patch
    let start = s:HunkStart()
    if start < 0
	return
    endif
    " Extract a line number from the hunk header
    let matches = matchlist(getline(start), '^@@ -\([0-9]\+\),\([0-9]\+\) +\([0-9]\+\),\([0-9]\+\)')
    return [ matches[1], matches[2], matches[3], matches[4] ]
endfunction

function s:HunkOldStart()
    let shape = s:HunkShape()
    return shape[0]
endfunction

function s:HunkOldLength()
    let shape = s:HunkShape()
    return shape[1]
endfunction

function s:HunkOldEnd()
    let shape = s:HunkShape()
    return shape[1]+shape[2]-1
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

function PatchSignoff()
    execute ":1,$!patch-signoff.pl"
endfunction

function PatchEditFile()
    let file = s:HunkFile()
    if file == ""
	return
    endif
    let here = line(".")
    let line = s:HunkOldStart()
    " Open a new buffer with the file and seek to the line
    execute ":new " . file
    execute ":" . (line + (here - s:FileStart() - 1))
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

function PatchExplain()
    let start = s:HunkStart()
    let end = s:HunkEnd()
    if end < 0 || start < 0
	return
    endif

    " Extract the patch context into a temp file
    let lno = start+1
    let context = []
    while lno <= end
	let ll = getline(lno)
	if ll =~ '^[ -]'
	    let context += [ strpart(ll, 1) ]
	endif
	let lno += 1
    endwhile
    let expectedfile = tempname()
    call writefile(context, expectedfile)

    " Extract the old file region into a temp file
    let actualfile = tempname()
    call system("sed -n -e '" . s:HunkOldStart() . "," . s:HunkOldEnd() . "p' " . s:HunkFile() . " > " . actualfile)

    execute(":new")
    execute(":r!diff -U0 " . expectedfile . " " . actualfile)
    call system("/bin/rm -f " . actualfile)
    call system("/bin/rm -f " . expectedfile)
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

" Load a scratch buffer with the given filename
" and return the given subset of lines in it
function PatchGetFileLines(fname, first, len)
    execute ":new"
    execute ":setlocal buftype=nofile"
    execute ":setlocal bufhidden=hide"
    execute ":setlocal noswapfile"
    execute ":read " . a:fname
    let lines = getline(a:first+1, a:first + 1 + a:len)
    execute ":quit"
    return lines
endfunction

function PatchTryApply()
    let patchfname = expand("%:p")
    let patchlines = getline(1,"$")
    let output = system("patch -p1 -f --dry-run 2>&1", join(patchlines, "\n") . "\n")

    " Scan the patch lines to find hunk boundaries
    " Build a dict which maps [file:hunknum] -> patch-line-num
    let hunkstarts = {}
    let hunkends = {}
    let fname = ""
    let hnum = 0
    let lnum = 1
    for line in patchlines
	if line =~ '^+++ '
	    if fname != ""
		if hnum != 0
		    let hunkends[fname . ":" . hnum] = lnum - 1
		endif
	    endif
	    let words = split(line)
	    let fname = words[1]

	    " Hardcoded to -p1
	    let fname = strpart(fname, stridx(fname, '/')+1)
	    let hnum = 1
	elseif line =~ '^@@ '
	    if fname != ""
		if hnum != 0
		    let hunkends[fname . ":" . (hnum-1)] = lnum - 1
		endif
		let hunkstarts[fname . ":" . hnum] = lnum
		let hnum = hnum + 1
"		echo "XX F " . fname . " H " . hnum . " -> " . lnum
	    endif
	endif
	let lnum = lnum + 1
    endfor
    if fname != ""
	if hnum != 0
	    let hunkends[fname . ":" . (hnum-1)] = lnum
	endif
    endif

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
	    let patchloc = patchfname . ":" . hunkstarts[fname . ":" . hnum]
	    let reports += [ patchloc . ": Hunk " . msg . " at " . fileloc ]
	elseif line =~ '^Hunk #[0-9]\+ FAILED at [0-9]\+\.$'
	    let hnum = matchstr(line, '[0-9]\+')
	    let flnum = matchstr(line, '[0-9]\+', 12)
	    let fileloc = fname . ":" . flnum
	    let hunkstart = hunkstarts[fname . ":" . hnum]
	    let hunkend = hunkends[fname . ":" . hnum]
	    let patchloc = patchfname . ":" . hunkstart
	    let reports += [ patchloc . ": Hunk FAILED at " . fileloc ]
	    let hunklines = getline(hunkstart+1, hunkend)
	    let len = hunkend - (hunkstart+1)
	    let contextlines = PatchGetFileLines(fname, flnum, len)
	    for hline in hunklines
		let hunkstart = hunkstart+1
		if hline !~ '^[- ]'
		    continue
		endif
		let hline = strpart(hline, 1)
		let found = -1
		for i in [0,1,2,3]
		    if hline == contextlines[i]
			let found = i
			break
		    endif
		endfor
		if found >= 0
		    let x = remove(contextlines, 0, found)
		else
		    let reports += [ patchfname . ":" . hunkstart . ": Bad context" ]
		endif
	    endfor

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

autocmd FileType diff map <buffer> <Leader>n :call PatchNormaliseHunk()<CR>
autocmd FileType diff map <buffer> <Leader>s :call PatchSignoff()<CR>
autocmd FileType diff map <buffer> <Leader>d :call PatchEditFile()<CR>
autocmd FileType diff map <buffer> <Leader>g :call PatchSelectHunk()<CR>
autocmd FileType diff map <buffer> <Leader>i :call PatchLinesIdentical()<CR>
autocmd FileType diff map <buffer> <Leader>a :call PatchTryApply()<CR>
autocmd FileType diff map <buffer> <Leader>x :call PatchExplain()<CR>
" The tricks for highlighting bad whitespace need to be
" adjusted for diffs.
autocmd FileType diff highlight clear BadLeadingWS
autocmd FileType diff highlight clear TrailingWS
autocmd FileType diff highlight PatchInvalidLead ctermbg=red
autocmd FileType diff let b:patch_match_1 = matchadd("PatchInvalidLead", "^[^-+ @]")
autocmd FileType diff highlight PatchBadLeadingWS ctermbg=red
autocmd FileType diff let b:patch_match_2 = matchadd("PatchBadLeadingWS", "\\%2v[ \t]* \t[ \t]*")
autocmd FileType diff highlight PatchTrailingWS ctermbg=red
autocmd FileType diff let b:patch_match_2 = matchadd("PatchTrailingWS", "\\%>1v[ \t]\\+$")

" autocmd FileType diff call PatchAddCommands()
