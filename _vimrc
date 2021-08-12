" This is an example of how _vimrc file should look on a Windows machine
" to make sure that one, common, configuration is kept under version
" control, is used.
"
" Source the .vimrc from vim-config repo

" Local vimrc file
let g:VIM_RC="h:\\dev\\projects\\vim-config\\.vimrc"

" Location of gvimfullscreen dll
let g:VIM_GVIMFULLSCREEN_DLL="h:\\dev\\projects\\gvimfullscreen_win32\\gvimfullscreen.dll"

try
    exec "source " . g:VIM_RC
catch
    echom "Cannot find the Vim configuration file: " . g:VIM_RC
endtry
