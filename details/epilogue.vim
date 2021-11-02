" This script contains stuff that needs to be invoked in the end of the .vimrc
" script's loading.
" NOTE: Depends on:
" - fullscreen.vim

" Force fullscreen upon entering GVim
if has('win32') && exists("g:VIM_GVIMFULLSCREEN_DLL")
    autocmd GUIEnter * call ForceFullscreen()
endif

" Clean up the highlight after refresh
noh
