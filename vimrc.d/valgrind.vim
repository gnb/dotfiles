function ValgrindLogBufReadPost()
    if getline(1) =~ '^==[0-9][0-9]*== Memcheck'
	set foldenable
	set foldcolumn=0
	set foldmethod=expr
	set foldexpr=ValgrindLogFoldFunction()
    endif
endfunction
function ValgrindLogFoldFunction()
    let l = getline(v:lnum)
    if l =~ '^==[0-9][0-9]*== [^ ]'
	return '>1'
    elseif l =~ '^==[0-9][0-9]*== $'
	return '='
    elseif l =~ '^==[0-9][0-9]*==  '
	return '='
    else
	return 0
    endif
endfunction
autocmd BufReadPost * call ValgrindLogBufReadPost()
