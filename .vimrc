if has('win32')
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
    :nnoremap <Leader>bb :buffers<CR>:b

    "" Folding
    "  Emulate IDE-like folding ability, so that it is possible to fold the code
    "  in {} block
    set foldmethod=indent
    set foldlevel=99
    nnoremap <Leader>f za

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
        call <SID>EnsurePackageInstalled("flake8")

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
        Plug 'embark-theme/vim'
    :call plug#end()

    " Plugin Install
    noremap <Leader>pi :source %<CR>:PlugInstall<CR>

    " Plugin Update
    noremap <Leader>pu :source %<CR>:PlugUpdate<CR>

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
    colorscheme embark

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
elseif has('unix') 
    if has('nvim')
        language messages en_US.utf8

        let mapleader = " "
        nnoremap <Space> <Nop>

        if exists("g:VIM_RC")
            " Quickly access this file
            noremap <silent> <Leader>v :execute 'edit!' g:VIM_RC<CR>:set number relativenumber<CR>:<ESC>

            " Quickly source current file
            noremap <silent> <Leader>s :wa<CR>:exe "source " . g:VIM_RC<CR>:call <SID>FixFullscreenAfterSource()<CR>
        else
            echom "You need to set VIM_RC variable so that it points to this file"
        endif

        " Map Ctrl-hjkl to move between windows
        map <C-h> <C-w>h
        map <C-j> <C-w>j
        map <C-k> <C-w>k
        map <C-l> <C-w>l

        nnoremap <silent> <Leader>/ :noh<CR>

        set number relativenumber

        :call plug#begin('$VIMRUNTIME/plugged')
            Plug 'junegunn/goyo.vim' " Distraction free editing
            Plug 'wincent/terminus'  " Change cursor depending on mode
				     " Baked into GVim, necessary in WSL.
	    Plug 'embark-theme/vim', { 'as': 'embark' }
            Plug 'morhetz/gruvbox'
        :call plug#end()

	" Enable 24-bit color support for nvim in Windows Terminal
	set termguicolors 
	colorscheme embark

        " Toggle Goyo (distration free writing)
        noremap <silent> <F3> :Goyo<CR>
    endif
endif
