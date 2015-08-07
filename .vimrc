set nocompatible

call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

filetype plugin indent on

function! ToggleMouse()
  if &mouse == 'a'
    set mouse=
    echo "Mouse usage disabled"
  else
    set mouse=a
    echo "Mouse usage enabled"
  endif
endfunction
nnoremap <leader>m :call ToggleMouse()<CR>

" Remember last location in file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal g'\"" | endif
endif


set backspace=indent,eol,start

set enc=utf-8

set nobackup

set wildmenu

set title
set ruler
set showcmd
set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)
set ruler
set laststatus=2
set number
set colorcolumn=80

set vb

set scrolljump=5
set scrolloff=3

set incsearch
set showmatch
set hlsearch
set ignorecase
set smartcase
"Clear the search highlight by pressing ENTER when in Normal mode (Typing commands)
:nnoremap <CR> :nohlsearch<CR>/<BS><CR>

set gdefault

set list listchars=tab:>·,trail:·

set nowrap
set autoindent
set smartindent
set expandtab
set shiftwidth=2
set tabstop=2
set softtabstop=2

vnoremap < <gv
vnoremap > >gv

set pastetoggle=<leader>v

"Solarized
set t_Co=256
let g:solarized_termcolors=256
colorscheme solarized
let g:solarized_termtrans=1
if has("gui_running")
    set guifont=Menlo\ Regular:h13
    set transparency=4
endif

syntax enable

"call togglebg#map("<leader>b")

" NERDTree
nmap <leader>nt :NERDTreeFind<CR>
let NERDTreeShowBookmarks=1
let NERDTreeChDirMode=0
let NERDTreeQuitOnOpen=1
let NERDTreeShowHidden=1
let NERDTreeKeepTreeInNewTab=1

" Copy current buffer path relative to root of VIM session to system clipboard
nnoremap <Leader>cp :let @*=expand("%")<cr>:echo "Copied file path to clipboard"<cr>
" Copy current filename to system clipboard
nnoremap <Leader>cf :let @*=expand("%:t")<cr>:echo "Copied file name to clipboard"<cr>
nnoremap <Leader>br :let @*='breakpoint set --file '.expand("%").' --line '.line(".")<cr>:echo "Copied file lldb breakpoint command"<cr>
"nnoremap y "+y
"vnoremap y "+y
set splitbelow
set splitright

" Alternate
nnoremap <Leader>h :A<CR>
nnoremap <Leader>l :IH<CR>
let g:alternateSearchPath='wdr:src'
let g:alternateExtensions_h = "c,cpp,cxx,cc,CC,mm"
let g:alternateExtensions_mm = "h,H,hpp,HPP"
"let g:ackprg='ack --nocolor --nogroup --column'
nnoremap <F8> :let mycurf=expand("<cfile>")<CR><C-w>k :execute("e ".mycurf)<CR><C-w>p
nnoremap <F9> :wincmd F<CR><C-w>x<C-w>k<C-w>k :close<CR>

nnoremap <leader>gg :Shell git grep -n <C-r><C-w> -- *.h *.cc *.cpp
nnoremap <leader>G :Shell git grep -n<space>
nnoremap <leader>F :Shell git ls-files \| fgrep<space>
nnoremap <leader>b :!~/tools/show_pull_request.sh <cword><cr>
nnoremap <leader>L :let cur_line=line(".") \| execute("!python ~/tools/open_line_in_browser.py '%:p' ".cur_line)<cr>

nnoremap <leader>ud :diffoff! <CR> :q<CR>
nmap tn :b#<CR>

set wildignore=*.o,*.obj,*~,*.pyc "stuff to ignore when tab completing
set wildignore+=.env[0-9]+
set wildignore+=.git
set wildignore+=.coverage
set wildignore+=*DS_Store*
set wildignore+=.sass-cache/
set wildignore+=__pycache__/
set wildignore+=vendor/rails/**
set wildignore+=vendor/cache/**
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=.tox/**
set wildignore+=.idea/**
set wildignore+=*.egg,*.egg-info
set wildignore+=*.png,*.jpg,*.gif
set wildignore+=*.so,*.swp,*.zip,*/.Trash/**,*.pdf,*.dmg,*/Library/**,*/.rbenv/**
set wildignore+=*/.nx/**,*.app

command W w
command WQ wq
command Wq wq
command Q q

"let $PATH .= ':/Users/kirr/yandex/browser_fork/src/buildtools/mac'
let g:ycm_global_ycm_extra_conf = '/Users/kirr/yandex/browser-master/src/tools/vim/chromium.ycm_extra_conf.py'
so ~/yandex/browser-master/src/tools/vim/ninja-build.vim
so ~/yandex/clang-format.vim
so ~/yandex/browser-master/src/tools/vim/filetypes.vim

"let g:ycm_auto_trigger = 0
set history=10000

let b:delimitMate_autoclose = 0
set completeopt-=preview

function! s:insert_gates()
  let gatename = substitute(toupper(expand("%")), "\\(\\.\\|/\\)", "_", "g") . "_"
  execute "normal! i#ifndef " . gatename
  execute "normal! o#define " . gatename
  execute "normal! Go#endif  // " . gatename
  normal! kk
endfunction

function! s:insert_copyright()
  let author_name = substitute(system("git config user.name"), "\\n", "", "g")
  let author_email = substitute(system("git config user.email"), "\\n", "", "g")
  execute "normal! i// Copyright (c) 2014 Yandex LLC. All rights reserved."
  execute "normal! oAuthor: " . author_name . " <" . author_email . ">"
  normal! kk
endfunction

autocmd BufNewFile *.{h,hpp} call <SID>insert_gates()
nnoremap <leader>gard :call <SID>insert_gates()<CR>
nnoremap <leader>cpr :call <SID>insert_copyright()<CR>

"let g:async = {'vim' : '/Applications/MacVim.app/Contents/MacOS/Vim'}
