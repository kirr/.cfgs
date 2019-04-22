set nocompatible
let mapleader = ','

call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-fugitive'

Plug 'junegunn/fzf.vim'

Plug 'bkad/CamelCaseMotion'

Plug 'scrooloose/nerdcommenter'

Plug 'tpope/vim-abolish'

Plug 'Shougo/deoplete.nvim'
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'
Plug 'zchee/deoplete-jedi'

Plug 'Glench/Vim-Jinja2-Syntax'
call plug#end()

let g:deoplete#enable_at_startup = 1
filetype plugin indent on

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

vnoremap <Up> <NOP>
vnoremap <Down> <NOP>
vnoremap <Left> <NOP>
vnoremap <Right> <NOP>
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

set pastetoggle=<leader>v

"Solarized
colorscheme solarized8
let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors
"set background=dark

syntax enable

"call togglebg#map("<leader>b")

" NERDTree
let NERDTreeShowBookmarks=1
let NERDTreeChDirMode=0
let NERDTreeQuitOnOpen=1
let NERDTreeShowHidden=1
let NERDTreeKeepTreeInNewTab=1

" Copy current buffer path relative to root of VIM session to system clipboard
nnoremap <Leader>cp :let @*=expand("%")<cr>:echo "Copied file path to clipboard"<cr>
" Copy current filename to system clipboard
nnoremap <Leader>cf :let @*=expand("%:t")<cr>:echo "Copied file name to clipboard"<cr>
nnoremap <Leader>br :let @*='breakpoint set --file '.expand("%:t").' --line '.line(".")<cr>:echo "Copied file lldb breakpoint command"<cr>
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

let g:asyncrun_open = 8
nnoremap <leader>ff :AsyncRun! rg --files -g "*<C-r><C-w>*"
nnoremap <leader>S :AsyncStop<CR>
nnoremap <leader>G :Rg <CR>
nnoremap <leader>rg :AsyncRun! rg --vimgrep -n <C-r><C-w> -tcpp
nnoremap <leader>F :Files<CR>
nnoremap <leader>B :Buffers<CR>
nnoremap <leader>li :Lines<CR>
nnoremap <leader>pr :!~/tools/show_pull_request.sh <cword><cr>
vnoremap <leader>bl <esc>:let line_start=line("'<") \| let line_end=line("'>") \| execute("AsyncRun!! git blame -L ".line_start.",".line_end." %")<cr>
nnoremap <leader>bl <esc>:let line_start=line(".") \| execute("AsyncRun! git blame -L ".line_start.",".line_start." %")<cr>
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

set cursorline
hi clear CursorLine
hi CursorLineNR cterm=bold ctermbg=cyan
augroup clcolor
  autocmd! ColorScheme * hi clear CursorLine
  autocmd! ColorScheme * hi CursorLineNR cterm=bold ctermbg=cyan
augroup end

"let g:ycm_auto_trigger = 0
set history=5000

let b:delimitMate_autoclose = 0
set completeopt-=preview
set shell=/bin/bash

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
  execute "normal! i# Copyright 2019 Yandex LLC. All rights reserved."
  normal! kk
endfunction

function! s:openFileInWindowAbove()
 let mycurf = expand("<cWORD>")
 let last_colon = stridx(mycurf, ":")
 if last_colon != -1
   let last_colon = stridx(mycurf, ":", last_colon + 1)
   if last_colon != -1
     let mycurf = strpart(mycurf, 0, last_colon)
   endif
 endif

 let window_count = winnr('$')
 let window_id = winnr()
 if window_count == 1
  sp
  let window_id = winnr()
 endif
 wincmd k
 if window_id == winnr()
  sp
  wincmd p
 endif
 execute "edit" mycurf
 wincmd p
endfunction

autocmd BufNewFile *.{h,hpp} call <SID>insert_gates()
nnoremap <leader>gard :call <SID>insert_gates()<CR>
nnoremap <leader>cpr :call <SID>insert_copyright()<CR>
"nnoremap <F8> :call <SID>openFileInWindowAbove()<CR>

set rtp+=/usr/local/opt/fzf
