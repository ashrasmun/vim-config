" This file contains settings that other scripts may most likely rely on. With
" that in mind, it's the first .vim script that should be invoked in the
" actual .vimrc so that other scripts can work properly.

" ---------------------------------- Leader ---------------------------------- "
let mapleader = " "
nnoremap <Space> <Nop>

" ---------------------------------- Python ---------------------------------- "
" This is needed because the python is loaded dynamically
if exists("g:VIM_PYTHON_PATH")
    " For some reason, I cannot simply use 'set' here. The only way to 'set'
    " these variables is to use 'let' + &...
    let &pythonhome=g:VIM_PYTHON_PATH
    let &pythondll=g:VIM_PYTHON_DLL
else
    echom "You need to set VIM_PYTHON_PATH in order to use Python"
endif

if exists("g:VIM_PYTHON_THREE_PATH")
    " For some reason, I cannot simply use 'set' here. The only way to 'set'
    " these variables is to use 'let' + &...
    let &pythonthreehome=g:VIM_PYTHON_THREE_PATH
    let &pythonthreedll=g:VIM_PYTHON_THREE_DLL
else
    echom "You need to set VIM_PYTHON_THREE_PATH in order to use Python3"
endif

" Silently invoke Python3 just to skip the annoying warning in the beginning.
" It's left out here for compatibility reasons (this shouldn't be a problem
" from Vim 8.2 onwards).
if has('python3')
    silent! python3 1
endif

" ---------------------------------- Plugin ---------------------------------- "
" Automatically install vim-plug if it's not present
if empty(glob('$VIMRUNTIME\autoload\plug.vim'))
    :let plug_vim_path=expand($VIMRUNTIME) . '\autoload\plug.vim'

    " The seemingly excessive escaping and quotations are needed when Vim is
    " installed into 'Program Files (x86)'.
    silent execute "!PowerShell \"Invoke-WebRequest -UseBasicParsing "
    \ . "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    \ . " | New-Item \\\"" . shellescape(plug_vim_path) . "\\\" -Force\""
endif

" ---------------------------------- Utils ----------------------------------- "
" Fetches desired color from the current colorscheme.
" Example: GetColor("Cursor", "guifg")
function! g:GetColor(group, option) abort
    redir => l:hi_color
    execute "silent! hi! " . a:group
    redir END

    let l:option_idx = strridx(l:hi_color, a:option)
    let l:value_only_idx = l:option_idx + 6
    let l:option_only = strpart(l:hi_color, l:value_only_idx, 7)

    return l:option_only
endfunction

" This function assumes, that the color is provided in #123456 format
function! g:GetColorValue(color_hex_code) abort
    return str2nr(strpart(a:color_hex_code, 1, 6), 16)
endfunction
