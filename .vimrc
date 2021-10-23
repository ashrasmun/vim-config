""" Fundamental
" Force english inside Vim
language messages en

" Enable completion list when writing in a command line (that bar in the very
" bottom :).)
set wildmenu

" Set leader key to space
:let mapleader = " "
:nnoremap <Space> <Nop>

:nnoremap <Leader>c :colorscheme
:nnoremap <silent> <Leader>e :set guifont=*<CR>

" Quickly access this file
if exists("g:VIM_RC")
    noremap <silent> <Leader>v :execute 'edit!' g:VIM_RC<CR>:set number relativenumber<CR>:<ESC>
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
if exists("g:VIM_RC")
    noremap <silent> <Leader>s :wa<CR>:exe "source " . g:VIM_RC<CR>:call <SID>FixFullscreenAfterSource()<CR>
else
    echom "You need to set VIM_RC variable so that it points to this file"
endif

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
" Keep the 'silent!' as it hides unimportant warnings when :Buffers is first
" invoked.
:nnoremap <Leader>bb :silent! Buffers<CR>

"" Folding
"  Emulate IDE-like folding ability, so that it is possible to fold the code
"  in {} block
set foldmethod=indent
set foldlevel=99

" Python
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

" Automatically install vim-plug if it's not present
if empty(glob('$VIMRUNTIME\autoload\plug.vim'))
    :let plug_vim_path=expand($VIMRUNTIME) . '\autoload\plug.vim'

    " The seemingly excessive escaping and quotations are needed when Vim is
    " installed into 'Program Files (x86)'.
    silent execute "!PowerShell \"Invoke-WebRequest -UseBasicParsing "
    \ . "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    \ . " | New-Item \\\"" . shellescape(plug_vim_path) . "\\\" -Force\""
endif

" Install python package if it's not yet installed
function! s:EnsurePackageInstalled(package) abort
    if exists("g:VIM_PYTHON_PATH")
        silent execute "!pyw -2.7 -m pip show " . a:package . " > nul"
        if v:shell_error==1
            silent execute "!py -2.7 -m pip install " . a:package . " && pause"
        endif
    endif

    if exists("g:VIM_PYTHON_THREE_PATH")
        silent execute "!pyw -3 -m pip show " . a:package . " > nul"
        if v:shell_error==1
            silent execute "!py -3 -m pip install " . a:package . " && pause"
        endif
    endif
endfunction

let plugin_location='$VIMRUNTIME\plugged'

:call plug#begin(plugin_location)
    Plug 'junegunn/goyo.vim'
    Plug 'tpope/vim-surround'

    " Enable . functionality for stuff from plugins, like vim-surround
    Plug 'tpope/vim-repeat'
    Plug 'scrooloose/nerdtree'

    " Let's you get to any word very quickly using <Leader><Leader> + w / b.
    " It also does way more, if you care to read the docs!
    Plug 'easymotion/vim-easymotion'

    " Real-time substitution preview
    Plug 'markonm/traces.vim'

    " File fuzzy searching
    " Windows How To:
    " 1. PlugInstall, as always. Disregard the errors related to temp files.
    " 2. Install fzf:
    "     a. cd $VIMRUNTIME\plugged\fzf
    "     b. powershell -ExecutionPolicy Bypass .\install --bin
    " 3. Install ripgrep - needed for :Rg. This tool makes you find stuff in
    "    files really fast.
    "    https://github.com/BurntSushi/ripgrep/releases
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'

    "" Programming related
    Plug 'cespare/vim-toml'

    "" C++
    " In progress...

    " Python
    Plug 'vim-scripts/indentpython.vim'
    Plug 'vim-syntastic/syntastic'
    " NOTE: You need to make sure that flake is installed.
    " :!py -3 -m pip show flake8
    " :!py -3 -m pip install flake8 && pause
    " Using EnsurePackageInstalled("flake8") takes a bit too much time on
    " every source...
    Plug 'nvie/vim-flake8'

    " JavaScript
    Plug 'pangloss/vim-javascript'

    " Colorschemes
    " Plug 'tyrannicaltoucan/vim-deep-space' " Quite ok, colorful, but still calm
    " Plug 'whatyouhide/vim-gotham'          " Quite ok
    " Plug 'cocopon/iceberg.vim'             " Quite ok, but split triggers me
    " Plug 'arzg/vim-substrata'              " +
    " Plug 'ludokng/vim-odyssey'             " +-
    " Plug 'seesleestak/duo-mini'            " +
    " Plug 'jacoborus/tender.vim'            " +
    " Plug 'tomasiser/vim-code-dark'         " well, it's vs
    " Plug 'embark-theme/vim'
    Plug 'nanotech/jellybeans.vim'  " Pretty minimalistic
:call plug#end()

" Plugin Install
noremap <Leader>pi :source %<CR>:PlugInstall<CR>

" Plugin Update
noremap <Leader>pu :source %<CR>:PlugUpdate<CR>

"" Syntastic
if exists("g:VIM_PYTHON_THREE_PATH")
    let g:syntastic_python_python_exec=g:VIM_PYTHON_THREE_PATH . "python.exe"
elseif exists("g:VIM_PYTHON_PATH")
    let g:syntastic_python_python_exec=g:VIM_PYTHON_PATH . "python.exe"
endif

"" Flake
if exists("g:VIM_PYTHON_THREE_PATH")
    let g:flake8_cmd=g:VIM_PYTHON_THREE_PATH . "python.exe"
elseif exists("g:VIM_PYTHON_PATH")
    let g:flake8_cmd=g:VIM_PYTHON_PATH . "python.exe"
endif

"" fzf

" Guarantee, that opening fzf in NERDTree is not going to happen. Instead, the
" next window's files are taken in such situation. This is mainly to not mess
" with NERDTree.
"
" Thanks, dkarter!
" https://github.com/junegunn/fzf/issues/453#issuecomment-354634207
function! FZFOpen(command_str)
  if (expand('%') =~# 'NERD_tree' && winnr('$') > 1)
    exe "normal! \<c-w>\<c-w>"
  endif
  exe 'normal! ' . a:command_str . "\<cr>"
endfunction

" Keep the 'silent!' as it hides unimportant warnings when :Files is first
" invoked.
noremap <Leader>f :call FZFOpen(':silent! Files %:h')<CR>

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

" Temporary, until it's moved somewhere else. At least now it's ina single
" 'block' of text.
if has('win32')
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
" Use 16 for streams, 12 for solo work
set guifont=Cascadia\ Code:h12,Consolas:h16,ProFontWindows:h14,Fira\ Mono:h14

" Interface clean-up
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
colorscheme jellybeans

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

"" Fonts
" This needs to be there - it's an initialization required on startup
set guifont=Cascadia\ Code:h12

let s:fontsize = 12
function! AdjustFontSize(amount)
  let s:fontsize = s:fontsize + a:amount
  execute "set guifont=Cascadia\\ Code:h" . s:fontsize

  " Make sure 'set guifont' has enough column to not excessively shrink the
  " window on resize.
  set columns=499
  set lines=499

  if libcallnr(g:VIM_GVIMFULLSCREEN_DLL, "QueryFullScreen", 0)
      call <SID>ForceFullscreen()
  endif

  execute "normal \<C-w>="
endfunction

noremap <C-Up> :call AdjustFontSize(1)<CR>
noremap <C-Down> :call AdjustFontSize(-1)<CR>
inoremap <C-Up> <Esc>:call AdjustFontSize(1)<CR>a
inoremap <C-Down> <Esc>:call AdjustFontSize(-1)<CR>a

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

" Clean up the highlight after refresh
noh
