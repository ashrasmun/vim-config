" This is an example of how _vimrc file should look on a Windows machine
" to make sure that one, common, configuration is kept under version
" control, is used.
"
" Source the .vimrc from vim-config repo

" Local vimrc file
let g:VIM_RC="h:\\dev\\projects\\vim-config\\.vimrc"

" Local Python library path that should be used by Vim pluggins
let g:VIM_PYTHON_PATH=resolve(expand($AppData . "\\..\\Local\\Programs\\Python\\Python27\\"))
let g:VIM_PYTHON_DLL="C:\\Windows\\System32\\python27.dll"
let g:VIM_PYTHON_THREE_PATH=resolve(expand($AppData . "\\..\\Local\\Programs\\Python\\Python39\\"))
let g:VIM_PYTHON_THREE_DLL=g:VIM_PYTHON_PATH . "\\python39.dll"

" Location of gvimfullscreen dll
let g:VIM_GVIMFULLSCREEN_DLL="h:\\dev\\projects\\gvimfullscreen_win32\\gvimfullscreen.dll"

try
    exec "source " . g:VIM_RC
catch
    echom "Cannot find the Vim configuration file: " . g:VIM_RC
endtry
