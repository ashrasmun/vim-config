if has('unix')

    " All system-wide defaults are set in $VIMRUNTIME/archlinux.vim (usually just
    " /usr/share/vim/vimfiles/archlinux.vim) and sourced by the call to :runtime
    " you can find below. If you wish to change any of those settings, you should
    " do it in this file (/etc/vimrc), since archlinux.vim will be overwritten
    " everytime an upgrade of the vim packages is performed. It is recommended to
    " make changes after sourcing archlinux.vim since it alters the value of the
    " 'compatible' option.

    " This line should not be removed as it ensures that various options are
    " properly set to work with the Vim-related packages.
    runtime! archlinux.vim

    " If you prefer the old-style vim functionalty, add 'runtime!
    " vimrc_example.vim' or better yet, read
    " /usr/share/vim/vim80/vimrc_example.vim or the vim manual
    " and configure vim to your own liking!

    " do not load defaults if ~/.vimrc is missing
    "let skip_defaults_vim=1
endif

""" Fundamental
" Force english inside Vim
language messages en

" Set leader key to space
:let mapleader = " "
:nnoremap <Space> <Nop>

:nnoremap <Leader>c :colorscheme
:nnoremap <silent> <Leader>e :set guifont=*<CR>

" Quickly access this file
if exists("g:VIM_RC")
    if has('unix')
        noremap <silent> <Leader>v :execute 'edit!' g:VIM_RC<CR>
    elseif has ('win32')
        noremap <silent> <Leader>v :execute 'edit!' g:VIM_RC<CR>:set number relativenumber<CR>:<ESC>
    endif
else
    echom "You need to set VIM_RC variable so that it points to this file"
endif

" On Windows, sourcing vimrc results in the window being in a really weird
" state. To fix that, the screen needs to be toggled twice at the end, so
" please don't add anything below this line.
" of function declaration in Vim script
function! s:FixFullscreenAfterSource() abort
    if has('win32')
        call <SID>ToggleFullscreen()
        call <SID>ToggleFullscreen()
    endif
endfunction

" Quickly source current file
:noremap <silent> <Leader>s :wa<CR>:exe "source " . g:VIM_RC<CR>:call <SID>FixFullscreenAfterSource()<CR>

" Remove highlight after searching
:noremap <silent> <Leader>/ :noh<CR>

"" Functions
" This function trims the whole file!
function! s:TrimTrailingWhitespaces() range
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfunction

:noremap <silent> <Leader>w :call <SID>TrimTrailingWhitespaces()<CR>

function! s:get_visual_selection()
    " Get the line and column of the visual selection marks
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]

    " Get all the lines represented by this range
    let lines = getline(line_start, line_end)

    if len(lines) == 0
        return ''
    endif

    " The last line might need to be cut if the visual
    " selection didn't end on the last column
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    " The first line might need to be trimmed if the visual
    " selection didn't start on the first column
    let lines[0] = lines[0][column_start - 1:]

    return join(lines, "\n")
endfunction

function! s:get_visual_line_selection()
    " Get the line and column of the visual selection marks
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]

    " Get all the lines represented by this range
    let lines = getline(line_start, line_end)

    if len(lines) == 0
        return ''
    endif

    return lines
endfunction

let g:my_debug_echom = 0
function! s:debug_echom(text)
    if g:my_debug_echom == 1
        echom a:text
    endif
endfunction

" TODO: Finish this
" TODO: Ask stackoverflow, why using count instead of _count results in
" variable being modified. That's a huge WTF moment
function! s:Columnize(_count, character, fline, lline) range abort
    call <SID>debug_echom("Calling with _count: " . a:_count . " and " . a:character)
    call <SID>debug_echom("Operation on range:" . a:fline . ":" . a:lline)
    let FindChar = { _count, char -> "0" . _count . "f" . char }
    let GoToLine = { line -> line . "G" }
    let s:tab_max_cl_idx = 0

    " Check if there's a 'count'th occurence of 'character' in line. If not,
    " leave, as columnization cannot be performed.
    for line in range(a:fline, a:lline)
        execute "normal! " . GoToLine(line) . FindChar(a:_count, a:character)

        " NOTE: This isn't a stable solution, as technically the character I
        " would like to 'columnize' to can be in the first column, but it's
        " highly unlikely. It would be nice to suggest a more robust solution.
        if virtcol('.') == 1
            call <SID>debug_echom("Cannot columnize - ending")
            return 1
        endif
    endfor

    " Cleanup whitespaces between the word and character
    " Why would we want to do it? We want to get rid of situations like the
    " ones below.
    " Example:
    " { asdf asdf         , sdlkfjsldkfj }
    " { slkdfjsldkfj, slfksjdlfk }
    " In this example, we would like to justify to the second row, not the
    " first one.
    let CleanupBeforeChar = { line, c -> ":" . line . "s/\\( \\|\\t\\)*" . c .
                \"/" . c . "/g"}
    for line in range(a:fline, a:lline)
        call <SID>debug_echom(CleanupBeforeChar(line, a:character))
        execute CleanupBeforeChar(line, a:character)
    endfor

    " Find the line with the furthest character
    let l:ref_line = -1
    for line in range(a:fline, a:lline)
        execute "normal! " . GoToLine(line) . FindChar(a:_count, a:character)
        let s:tab_cur_cl_idx = virtcol('.')

        if s:tab_cur_cl_idx > s:tab_max_cl_idx
            let s:tab_max_cl_idx = s:tab_cur_cl_idx
            call <SID>debug_echom("max @: " . s:tab_max_cl_idx)
            let l:ref_line = line
        endif
    endfor

    if strwidth(getline(ref_line)) <= s:tab_max_cl_idx
        call <SID>debug_echom("End of the line reached - nothing to indent")
        return 1
    endif

    " Trying to make the command more readable:
    " 'c' is the character, in this example it's ','
    " 'i' is the index, in this example it's '1'
    " The first group is captured twice, mainly because I don't know how to
    " create a non-capturing group in VimScript
    " s/\(^\([^,]*[,]\)\{-1}\)\( \|\t\)*\(.*$\)/\1\t\4
    let MatchToChar     = { i, c -> "\\(^\\([^" . c . "]*[" . c . "]\\)\\{-" . i . "}\\)" }
    let MatchSpaceOrTab = { -> "\\( \\|\\t\\)*" }
    let MatchTillEnd    = { -> "\\(.*$\\)" }

    " Remove superfluous spaces / tabs between the character to which we want
    " to tabularize all the text
    execute "normal! " . GoToLine(ref_line)
    let RemoveSuperfluousWhitespaces =
                \{ line -> ":" . line . "s/"
                \. MatchToChar(a:_count, a:character) . MatchSpaceOrTab() . MatchTillEnd()
                \. "/\\1\<tab>\\4" }

    execute RemoveSuperfluousWhitespaces(ref_line)
    execute "normal! " . GoToLine(ref_line) . FindChar(a:_count, a:character) . "W"
    let s:ref_col = virtcol('.') - 1
    call <SID>debug_echom("Everything should be columnized to " . s:ref_col)

    " Iterate through other lines and tab the word after first 'character'
    " until the cursor is on 'column index'.
    for line in range(a:fline, a:lline)
        if line == ref_line
            continue
        endif

        execute RemoveSuperfluousWhitespaces(line)
        execute "normal! " . GoToLine(line) . FindChar(a:_count, a:character) . "W"

        call <SID>debug_echom(virtcol('.') . " " . s:ref_col)
        while virtcol('.') < s:ref_col
            call <SID>debug_echom("Moving " . virtcol('.') . " to " . s:ref_col)
            execute "normal! i\<tab>"
            execute "normal! l"
        endwhile
    endfor

    call <SID>debug_echom("Cleanup")
    " Make the tabulation consistent in the line
    :'<,'>retab

    return 0
endfunction

" This function exists, because recursion of function, that is editing stuff in
" file is not reliable. It's safer to just invoke the function in iterative
" manner.
function! s:ColumnizeN(character) range
    let i = 0
    let rc = 0
    while !rc
        let i = i + 1
        " This is needed, as a:firstline and a:lastline are not propagated to
        " further functions
        let rc = <SID>Columnize(i, a:character, a:firstline, a:lastline)
    endwhile
endfunction

command! -nargs=1 -range J <line1>,<line2>call <SID>ColumnizeN(<f-args>)

" Joins multiple lines into one line without producing any spaces
" Like gJ, but always remove spaces
function! s:JoinSpaceless()
    execute 'normal gJ'

    " Character under cursor is whitespace?
    if matchstr(getline('.'), '\%' . col('.') . 'c.') =~ '\s'
        " Then remove it!
        execute 'normal dw'
    endif
endfunction

:noremap <silent> <Leader>J :call <SID>JoinSpaceless()<CR>

" Remove all buffers but the one opened
function! s:DeleteBuffersExceptOpened()
    execute '%bdelete|edit #|normal `'
endfunction

:noremap <Leader>bd :call <SID>DeleteBuffersExceptOpened()<CR>

"" Choose buffer
:nnoremap <Leader>bb :buffers<CR>:b

"" Folding
"  Emulate IDE-like folding ability, so that it is possible to fold the code
"  in {} block
set foldmethod=indent
set foldlevel=99
nnoremap <Leader>f za

"" Python
" " This is needed because the python is loaded dynamically
" if exists("g:VIM_PYTHON_PATH")
"     " For some reason, I cannot simply use 'set' here. The only way to 'set'
"     " these variables is to use 'let' + &...
"     let &pythonthreehome=g:VIM_PYTHON_PATH
"     let &pythonthreedll=g:VIM_PYTHON_DLL
" else
"     echom "You need to set VIM_PYTHON_PATH in order to use Python"
" endif

" Silently invoke Python3 just to skip the annoying warning in the beginning.
" It's left out here for compatibility reasons (this shouldn't be a problem
" from Vim 8.2 onwards).
if has('python3')
    silent! python3 1
endif

function! s:set_indentation_rules() abort
    set tabstop=4
    set softtabstop=4
    set shiftwidth=4
    set textwidth=79
    set expandtab
    set autoindent
    set fileformat=unix
endfunction

" Add proper PEP8 indentation
autocmd BufNewFile,BufRead *.py call <SID>set_indentation_rules()

" Propagate these settings to C-family of langauges
autocmd BufNewFile,BufRead *.c   call <SID>set_indentation_rules()
autocmd BufNewFile,BufRead *.cc  call <SID>set_indentation_rules()
autocmd BufNewFile,BufRead *.cpp call <SID>set_indentation_rules()
autocmd BufNewFile,BufRead *.h   call <SID>set_indentation_rules()

let python_highlight_all=1

" Enable line numbering
:set number relativenumber

" Highlight the searched result by default
:set hlsearch

" Give myself at least some basic information about the text file
if has('win32')
    set ruler
endif

" Remove all the swap / undo / backup files
:set noundofile
:set noswapfile
:set nobackup
:set nowritebackup

" Makes the automatic tabs 4 spaces wide instead of 8 (!)
:set expandtab
:set softtabstop=4
:set shiftwidth=4
:set tabstop=4

" Accept Unicode characters
:set encoding=utf-8

" Writes trailing characters
set listchars=tab:>-,trail:-,nbsp:_
set list

" Enable syntax highlighting
:syntax on

" Turn off file specific vim on-demand formatting
set nomodeline

" If searching in lowercase, ignore casing. Otherwise, check for a specific
" string and take font case into consideration
set ignorecase
set smartcase
set incsearch
set hlsearch

" Fix backspace behaviour
set backspace=indent,eol,start

""" Plugins
"" Load plugins (vim-plug)
"
" To install plugins, find the Plug '' section for given plugin
" then run :source % and :PlugInstall (not :PluginInstall)
"
" To disable a plugin, add:
" , { 'on': [] }
" in the end of the line in plug section. For example:
" Enabled:  Plug 'junegunn/goyo.vim'
" Disabled: Plug 'junegunn/goyo.vim', { 'on': [] }
"
" Automatically install vim-plug if it's not present
if has('unix')
    if empty(glob('~/.vim/autoload/plug.vim'))
        silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        autocmd VimEnter * PlugInstall --sync | source g:VIM_RC
    endif
endif

let plugin_location=''
if has('unix')
    let plugin_location='~/.vim/plugged'
elseif has('win32')
    let plugin_location='$VIMRUNTIME\plugged'
endif

:call plug#begin(plugin_location)
    Plug 'junegunn/goyo.vim'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-repeat'
    Plug 'scrooloose/nerdtree'
    Plug 'easymotion/vim-easymotion'

    " Smooth scrolling when using Ctrl-d, Ctrl-u
    "Plug 'psliwka/vim-smoothie' " , { 'on': [] }

    " Real-time substitution preview
    Plug 'markonm/traces.vim'

    " File fuzzy searching
    " I cannot make it work...
    "Plug 'kien/ctrlp.vim'

    "" Programming related
    Plug 'cespare/vim-toml'

    "" C++
    " In progress...

    " Python
    Plug 'vim-scripts/indentpython.vim'
    Plug 'vim-syntastic/syntastic'
    Plug 'nvie/vim-flake8'

    " JavaScript
    Plug 'pangloss/vim-javascript'

    " Colorschemes
    Plug 'tyrannicaltoucan/vim-deep-space' " Quite ok, colorful, but still calm
    Plug 'whatyouhide/vim-gotham'          " Quite ok
    Plug 'cocopon/iceberg.vim'             " Quite ok, but split triggers me
    Plug 'arzg/vim-substrata'              " +
    Plug 'ludokng/vim-odyssey'             " +-
    Plug 'seesleestak/duo-mini'            " +
    Plug 'jacoborus/tender.vim'            " +
    Plug 'tomasiser/vim-code-dark'         " well, it's vs
    Plug 'embark-theme/vim'                " 

    " Linux specific plugins
    if has('unix')
        " https://github.com/lyuts/vim-rtags
        Plug 'lyuts/vim-rtags'

        " https://vimawesome.com/plugin/vim-airline-superman
        Plug 'vim-airline/vim-airline'
        Plug 'vim-airline/vim-airline-themes'
    endif
:call plug#end()

" Plugin Install
noremap <Leader>pi :source %<CR>:PlugInstall<CR>

" Plugin Update
noremap <Leader>pu :source %<CR>:PlugUpdate<CR>

"" vim-airline config
if has('unix')
    " Setup the airline bar with fancy fonts
    set t_Co=256
    let g:airline_powerline_fonts = 1

    if !exists('g:airline_symbols')
      let g:airline_symbols = {}
    endif

    let g:airline_symbols.space = "\ua0"
endif

"" NERDTree
" Invoke nerd tree every time vim is opened
" and focus on buffer with file
" autocmd VimEnter * NERDTree | wincmd w

" Close vim when NERDTree buffer is the only one present
" In case of emergency, visit:
" https://stackoverflow.com/questions/2066590/automatically-quit-vim-if-nerdtree-is-last-and-only-buffer
autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Toggle mini file explorer
noremap <Leader>nt :NERDTreeToggle<CR>
noremap <Leader>nf :NERDTreeFind<CR>

"" Goyo config
" Toggle Goyo (distration free writing)

" Make Goyo as wide as this line
" ============================================================================ "
let g:goyo_width=80

if has('unix')
    noremap <silent> <F3> :Goyo<Enter>

    function! s:init_on_entering_goyo()
        silent !i3-msg fullscreen enable
        set number relativenumber
    endfunction

    function! s:clean_up_after_colon_qing_goyo()
        silent !i3-msg fullscreen disable
        call <SID>restore_highlight_settings()
        " TODO: Move cursor to the previous buffer
    endfunction

    autocmd! User GoyoEnter nested call <SID>init_on_entering_goyo()
    autocmd! User GoyoLeave nested call <SID>clean_up_after_colon_qing_goyo()
elseif has('win32')
    " Make GVim fullscreen on startup
    " Don't feel tempted to use 64-bit version of this, as it doesn't work
    " REQUIRES: https://github.com/derekmcloughlin/gvimfullscreen_win32/tree/master

    " Location of the fullscreen fixer dll

    function! s:ToggleFullscreen() abort
        let l:bg_color = s:get_color("Normal", "guibg")
        let l:bg_color_value = s:value_only(bg_color)

        if !l:bg_color_value
            echom 's:ToggleFullscreen: The color value is probably
                        \not set properly'
            return
        endif

        silent call libcallnr(g:VIM_GVIMFULLSCREEN_DLL, "SetBackgroundColor", bg_color_value)
        silent call libcallnr(g:VIM_GVIMFULLSCREEN_DLL, "ToggleFullScreen", 0)
        redraw
    endfunction

    function! s:ForceFullscreen() abort
        let l:bg_color = s:get_color("Normal", "guibg")
        let l:bg_color_value = s:value_only(bg_color)

        if !l:bg_color_value
            echom 's:ForceFullscreen: The color value is probably
                        \not set properly'
            return
        endif

        silent call libcallnr(g:VIM_GVIMFULLSCREEN_DLL, "SetBackgroundColor", bg_color_value)
        silent call libcallnr(g:VIM_GVIMFULLSCREEN_DLL, "ToggleFullScreen", 1)
        redraw!
    endfunction

    function! s:ForceDoubleFullscreen() abort
        call libcallnr(g:VIM_GVIMFULLSCREEN_DLL, "ToggleFullScreen", 3)
        redraw
    endfunction

    autocmd GUIEnter * call <SID>ForceFullscreen()
    noremap <silent> <F11> :call <SID>ToggleFullscreen()<CR>
    noremap <silent> <F12> :call <SID>ForceFullscreen()<CR>
    noremap <silent> <s-F12> :call <SID>ForceDoubleFullscreen()<CR>

    " This function is here only to fix Goyo's behaviour in GVim while using the
    " gvimfullscreen.dll. Goyo methods are a bit unreliable, so we need to run
    " separate function after Goyo is done doing what it's doing.
    function! s:FullscreenFix()
        " Both of these are needed as Goyo doesn't cope well with colorscheme
        " manipulation mixed with screen resolution fiddling. It looks
        " completely horrible on Windows, but it's the only known method for
        " me to make it work...
        if g:goyo_state
            call <SID>ForceFullscreen()
        else
            call <SID>ToggleFullscreen()
            call <SID>ToggleFullscreen()
        endif
    endfunction

    " 0 - outside Goyo
    " 1 - in Goyo
    let g:goyo_state=0

    "" Goyo config
    function! s:goyo_enter()
        let g:goyo_state = 1

        " This works for 'nord' colorscheme
        let l:eob_color = s:get_color("ColorColumn", "guifg")
        silent! execute "highlight EndOfBuffer guifg=" . l:eob_color

        set number relativenumber
    endfunction

    " This supports leaving Goyo via :x, :q etc
    function! s:goyo_leave()
        let g:goyo_state = 0
    endfunction

    autocmd! User GoyoEnter call <SID>goyo_enter()
    autocmd! User GoyoLeave call <SID>goyo_leave()

    " Toggle Goyo (distration free writing)
    noremap <silent> <F3> :Goyo<CR>:call <SID>FullscreenFix()<CR>
endif

"" Fonts
if has('win32')
    " set guifont=Consolas:h15
    " set guifont=Fira\ Mono:h16
    " set guifont=Inconsolata:h14
    " set guifont=monofur:h14
    set guifont=Consolas:h16,ProFontWindows:h14,Fira\ Mono:h14
endif

" Remove background from vertical splits to make it less noisy
function! s:restore_highlight_settings()
    :highlight VertSplit cterm=NONE ctermfg=8
    :highlight StatusLineNC ctermfg=0
    :highlight clear CursorLineNr
    :highlight CursorLineNr cterm=bold
endfunction

" Interface clean-up
if has('unix')
    call <SID>restore_highlight_settings()
elseif has('win32')
    " The only variation of vim usable on Windows is GVim, so all the settings
    " assume it's usage

    " Remove background from vertical splits to make it less noisy.
    :highlight VertSplit guibg=black guifg=white
    :highlight StatusLineNC guibg=black guifg=white

    " Remove GUI components
    set guioptions-=m " menu bar
    set guioptions-=T " toolbar
    set guioptions-=r " right-hand scroll bar
    set guioptions-=L " left-hand scroll bar
    set guioptions-=M " left-hand scroll bar
endif

""" Graphics

" Set the delimiter to something less noisy
" for example tmux's separator character
:set fillchars+=vert:│

" Treat underscores as "word" separators
" :set iskeyword-=_

" Fetches desired color from the current colorscheme.
" Example: get_color("Cursor", "guifg")
function! s:get_color(group, option) abort
    redir => l:hi_color
    execute "silent! hi! " . a:group
    redir END

    let l:option_idx = strridx(l:hi_color, a:option)
    let l:value_only_idx = l:option_idx + 6
    let l:option_only = strpart(l:hi_color, l:value_only_idx, 7)

    return l:option_only
endfunction

" This function assumes, that the color is provided in #123456 format
function! s:value_only(color_hex_code) abort
    return str2nr(strpart(a:color_hex_code, 1, 6), 16)
endfunction

" Make sure that color of the background for line numbers is the same
" as the normal background
function! s:normalize_bg_color() abort
    let l:normal_bg_color = s:get_color("Normal", "guibg")
    execute "hi LineNr guibg=" . l:normal_bg_color
endfunction

" https://gist.github.com/romainl/379904f91fa40533175dfaec4c833f2f
function! s:my_highlights() abort
    highlight VertSplit cterm=NONE ctermfg=8
    highlight StatusLineNC ctermfg=0
    highlight clear CursorLineNr
    highlight CursorLineNr cterm=bold

    silent! call <SID>normalize_bg_color()
endfunction

augroup MyColors
    autocmd!
    autocmd ColorScheme * call <SID>my_highlights()
augroup END

" Colorscheme setting needs to be done AFTER setting highlight colors
" That way, the colorscheme can react and change accordingly
if has('unix')
    " Set the colorscheme to the one fitting pywal's settings
    colorscheme wal
elseif has('win32')
    " 'pywal' is unavailable on Windows, but 'nord' is a very nice colorscheme
    " colorscheme gotham256
    " colorscheme nord
    " colorscheme gruvbox
    " colorscheme substrata
    " colorscheme deep-space
    colorscheme iceberg
endif

""" Keybindings
" Map Ctrl-hjkl to move between windows
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Enable these mappings for terminal as well
tmap <C-h> <C-w>h
tmap <C-j> <C-w>j
tmap <C-k> <C-w>k
tmap <C-l> <C-w>l

"" Formatting
command! FormatXML :%!python -c "import xml.dom.minidom, sys; print(xml.dom.minidom.parse(sys.stdin).toprettyxml())"
command! FormatJSON :%!python -m json.tool

" TODO(05-05-20, ashrasmun): add leader key mappings for:
" Starts with 'd', because of development
" 1. compile code: <Leader>dc ?
" 2. execute code: <Leader>dx ?
" 3. set compile command: <Leader> dsc
" 4. set execute command: <Leader> dsx

" Tips and Tricks:
"
" Execute command without need to press ENTER after it's invocation:
" :exe ":!<command>" | redraw
"
" Run last command:
" @:
