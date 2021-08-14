# vim-config
My Vim configuration, more precisely GVim.

## Setup
0. Install Vim (duh)
1. Install [vim-plug](https://github.com/junegunn/vim-plug)
2. Install [vim-flake8](https://github.com/nvie/vim-flake8)
3. Clone the repo
4. Place the `_vimrc` in proper location - by default, it should be `C:\Program Files\(x86)\Vim\_vimrc`. That's going to be the file in which you redirect to repository files.
5. Setup [gvimfullscreen_win32](https://github.com/ashrasmun/gvimfullscreen_win32)
6. Set the `g:VIM_RC` and `g:VIM_GVIMFULLSCREEN_DLL` variables to point to proper locations on your hard drive.
7. Copy `.flake8` to `%appdata%\..` (Windows' "home")
8. You're done :)

## File associations
If you want to associate certain file types with GVim, you should copy `gvim_remote_silent.bat` to location where you have your `gvim.exe` (or modify the script accordingly, you do you...). Then, you should point to the batch file with _Right Click_ -> "Open With..." option. Voila!
