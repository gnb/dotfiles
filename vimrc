set autoindent
set shiftwidth=4
set softtabstop=4
set tabstop=8
set textwidth=72
set formatoptions+=cro
" Remember:  gq]/  formats to the end of the comment
set nowrap
syntax on
highlight Comment ctermfg=darkgrey
set exrc
set modeline
set modelines=5
" Highlight trailing whitespace in red
highlight TrailingWS ctermbg=red
let m = matchadd("TrailingWS", "[ \t]\\+$")
" Highlight non-normalised leading whitespace in red
" where normalised means all the tabs are at the front
highlight BadLeadingWS ctermbg=red
let m = matchadd("BadLeadingWS", "^[ \t]* \t[ \t]*")
highlight BadLeadingWS2 ctermbg=red
let m = matchadd("BadLeadingWS2", "^\t* \\{8,\\}[ \t]*")
" make Alt-C comment out a line in various modes
autocmd FileType perl map <buffer> <Esc>c 0i# <Esc>j
autocmd FileType sh map <buffer> <Esc>c 0i# <Esc>j
autocmd FileType spec map <buffer> <Esc>c 0i# <Esc>j
autocmd FileType make map <buffer> <Esc>c 0i# <Esc>j
autocmd FileType conf map <buffer> <Esc>c 0i# <Esc>j
autocmd FileType automake map <buffer> <Esc>c 0i# <Esc>j
autocmd FileType python map <buffer> <Esc>c 0i# <Esc>j
autocmd FileType c map <buffer> <Esc>c 0i// <Esc>j
autocmd FileType cpp map <buffer> <Esc>c 0i// <Esc>j
autocmd FileType php map <buffer> <Esc>c 0i// <Esc>j
autocmd FileType mail map <buffer> <Esc>c 0i> <Esc>j
autocmd FileType tex map <buffer> <Esc>c 0i% <Esc>j
autocmd FileType javascript map <buffer> <Esc>c 0i// <Esc>j
autocmd FileType c map <buffer> <Esc>n :cn<CR>
source ~/.vimrc.d/patch.vim
source ~/.vimrc.d/cscope.vim
source ~/.vimrc.d/quilt.vim
source ~/.vimrc.d/valgrind.vim
