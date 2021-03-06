"
" PEP8 compatible settings
" https://www.python.org/dev/peps/pep-0008/
"
function PythonPEP8Setup()
    " remove all highlights
    highlight clear
    " highlight tabs in leading whitespace
    highlight BadLeadingWS ctermbg=red
    let m = matchadd("BadLeadingWS", "^[ \t]*\t[ \t]*")
    " highlight trailing whitespace
    highlight TrailingWS ctermbg=red
    let m = matchadd("TrailingWS", "[ \t]\\+$")
    " fold lines at 79 chars
    set textwidth=79
    " 4-space indents with no tabs
    set shiftwidth=4
    set softtabstop=4
    set tabstop=8
    set expandtab
endfunction

autocmd FileType python call PythonPEP8Setup()
