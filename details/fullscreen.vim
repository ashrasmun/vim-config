" This script contains fullscreen related functionality that is tightly
" coupled with both GVim and the gvim_fullscreen.dll library.
" NOTE: Depends on:
" - prologue.vim

if !has('win32')
    echom "You need to be on Windows in order to use functionality from fullscreen.vim"
    finish
endif

if !exists("g:VIM_GVIMFULLSCREEN_DLL")
    echom "You need to set the path to gvimfullscreen.dll, built from https://github.com/ashrasmun/gvimfullscreen_win32"
    finish
endif

function! g:ToggleFullscreen() abort
    let l:bg_color = g:GetColor("Normal", "guibg")
    let l:bg_color_value = g:GetColorValue(bg_color)

    if !l:bg_color_value
        echom 'g:ToggleFullscreen: The color value is probably not set properly'
        return
    endif

    silent call libcallnr(g:VIM_GVIMFULLSCREEN_DLL, "SetBackgroundColor", bg_color_value)
    silent call libcallnr(g:VIM_GVIMFULLSCREEN_DLL, "ToggleFullScreen", 0)
    redraw
endfunction

function! g:ForceFullscreen() abort
    let l:bg_color = g:GetColor("Normal", "guibg")
    let l:bg_color_value = g:GetColorValue(bg_color)

    if !l:bg_color_value
        echom 'g:ForceFullscreen: The color value is probably not set properly'
        return
    endif

    silent call libcallnr(g:VIM_GVIMFULLSCREEN_DLL, "SetBackgroundColor", bg_color_value)
    silent call libcallnr(g:VIM_GVIMFULLSCREEN_DLL, "ToggleFullScreen", 1)
    redraw!
endfunction

function! g:ForceDoubleFullscreen() abort
    call libcallnr(g:VIM_GVIMFULLSCREEN_DLL, "ToggleFullScreen", 3)
    redraw
endfunction

noremap <silent> <F11> :call ToggleFullscreen()<CR>
noremap <silent> <F12> :call ForceFullscreen()<CR>
noremap <silent> <s-F12> :call ForceDoubleFullscreen()<CR>

" On Windows, sourcing vimrc results in the window being in a really weird
" state. To fix that, the screen needs to be toggled twice at the end.
function! FixFullscreenAfterSource() abort
    call ToggleFullscreen()
    call ToggleFullscreen()
endfunction
