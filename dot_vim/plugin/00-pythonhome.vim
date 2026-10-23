" Debian vim is linked against the system libpython, but CPython 3.8+ locates
" its standard library from the first python3 on PATH. mise's Python is a
" different build: _ctypes is compiled into that interpreter, so Vim cannot
" load it and the apt powerline module is invisible. Keep the embedded
" interpreter on the system prefix. This file is deployed by chezmoi, so it
" applies on every machine. It must run before powerline.vim.
if exists('+pythonthreehome')
  set pythonthreehome=/usr
endif

" Setting g:powerline_loaded in a personal vimrc makes powerline.vim exit
" immediately. That hides the import error and also disables the statusline.
" Drop it here so the same vimrc cannot leave other machines without powerline.
if exists('g:powerline_loaded')
  unlet g:powerline_loaded
endif
