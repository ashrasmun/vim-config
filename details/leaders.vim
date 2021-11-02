" This file contains leader key mappings that are unrelated to anything in
" particular.
" NOTE: Depends on:
" - fullscreen.vim

nnoremap <Leader>c :Colors<CR>
nnoremap <silent> <Leader>e :set guifont=*<CR>

" Remove highlight after searching
nnoremap <silent> <Leader>/ :noh<CR>

if exists("g:VIM_RC")
    " Quickly access the main .vimrc file
    nnoremap <silent> <Leader>v :execute 'edit!' g:VIM_RC<CR>:set number relativenumber<CR>:<ESC>

    " Quickly source current file
    nnoremap <silent> <Leader>s :wa<CR>:exe "source " . g:VIM_RC<CR>:call <SID>FixFullscreenAfterSource()<CR>
else
    echom "You need to set VIM_RC variable so that it points to the main .vimrc file"
endif
