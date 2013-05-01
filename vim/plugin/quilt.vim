"
" Quilt support
"
" Searches back up the from the current directory to root,
" looking for the two directories that are important to quilt,
" and initialises the following global vim variables:
"
" g:quilt_source_dir	Root of the tree under which quilt-controlled
"			source lives.  Quilt emits filenames relative
"			to this directory.
"
" g:quilt_patches_dir	Directory in which patches are stored, typically
"			called patches/ in either the source_dir or some
"			ancestor of it.
"
" Both of these must be non-empty if we've been started in
" a valid quilt tree.
"
function QuiltInit()
    let dir = getcwd()
    let g:quilt_source_dir = ""
    let g:quilt_patches_dir = ""
    while 1
	if filereadable(dir . "/.novimquilt")
	    let g:quilt_source_dir = ""
	    let g:quilt_patches_dir = ""
	    return
	endif
	if isdirectory(dir . "/patches") && filereadable(dir . "/patches/series")
	    let g:quilt_patches_dir = dir . "/patches"
	endif
	if isdirectory(dir . "/.pc") && filereadable(dir . "/.pc/applied-patches")
	    let g:quilt_source_dir = dir
	endif
	if g:quilt_patches_dir != ""
	    break
	endif
	    break
	if dir == "/"
	    break
	endif
	let i = strridx(dir, "/")
	if i == 0
	    let dir = "/"
	else
	    let dir = strpart(dir, 0, i)
	endif
    endwhile
endfunction
call QuiltInit()
"
function QuiltBufReadPre()
    " default values
    let b:quilt_in_patch = 0
    let b:quilt_name = ""
    if g:quilt_patches_dir != "" && g:quilt_source_dir != ""
	let fname = expand("%:p")
	if strpart(fname, 0, strlen(g:quilt_source_dir)) == g:quilt_source_dir
	    let relname = strpart(fname, strlen(g:quilt_source_dir)+1)
	    let dir1 = strpart(relname, 0, stridx(relname, "/"))
	    if (dir1 != "patches" && dir1 != ".pc" && relname != "x.patch" && relname != "TODO")
		let b:quilt_name = relname
		let inpatch = system("quilt files 2>/dev/null| grep '^" . b:quilt_name . "$'")
		if inpatch == ""
		    let b:quilt_in_patch = 0
		    set ro
		else
		    let b:quilt_in_patch = 1
		endif
	    endif
	endif
    endif
endfunction
autocmd BufReadPre * call QuiltBufReadPre()
"
function QuiltFileChangedRO()
    if b:quilt_name != "" && b:quilt_in_patch == 0
	let res = input("Add " . b:quilt_name . " to top patch ([y]/n)? ", "y")
	if res == "y"
	    echomsg system("cd " . g:quilt_source_dir . "; quilt add " . b:quilt_name)
	    let b:quilt_in_patch = 1
	    set noro
	    checktime "%"
	endif
    endif
endfunction
autocmd FileChangedRO * call QuiltFileChangedRO()
