" the following is straight out of the vim online help
" and makes cscope support easy to use
if has("cscope")
	if filereadable("/usr/bin/cscope")
	    set csprg=/usr/bin/cscope
	elseif filereadable("/usr/local/bin/cscope")
	    set csprg=/usr/local/bin/cscope
	elseif filereadable("/Library/CScope/bin/cscope")
	    set csprg=/Library/CScope/bin/cscope
	endif
	set csto=0
	set cst
	set nocsverb
	" add any database in current directory
	if filereadable("cscope.out")
	    cs add cscope.out
	" else add database pointed to by environment
	elseif $CSCOPE_DB != ""
	    cs add $CSCOPE_DB
	endif
	set csverb
endif
