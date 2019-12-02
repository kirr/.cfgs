set nocompatible
set nofixendofline
let mapleader = ','

function! BuildYCM(info)
  " info is a dictionary with 3 fields
  " - name:   name of the plugin
  " - status: 'installed', 'updated', or 'unchanged'
  " - force:  set on PlugInstall! or PlugUpdate!
  if a:info.status == 'installed' || a:info.force
    !./install.py --clang-completer
  endif
endfunction

call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-fugitive'

Plug 'junegunn/fzf.vim'

Plug 'bkad/CamelCaseMotion'

Plug 'scrooloose/nerdcommenter'

Plug 'tpope/vim-abolish'

" Plug 'Shougo/deoplete.nvim'
" Plug 'zchee/deoplete-jedi'
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'
Plug 'Valloric/YouCompleteMe'

Plug 'Glench/Vim-Jinja2-Syntax'

" Plug 'hauleth/asyncdo.vim'
" Plug 'romainl/vim-qf'
Plug 'mhinz/vim-grepper'
Plug 'vim-scripts/vcscommand.vim'
Plug 'markonm/traces.vim'
Plug 'derekwyatt/vim-fswitch'
Plug 'phleet/vim-mercenary'
Plug 'moll/vim-bbye'
call plug#end()

let g:mercenary_hg_executable = './ya tool hg'
let g:ycm_show_diagnostics_ui = 0
let g:fsnonewfiles = 1
let g:grepper = {'quickfix': 0}
" let g:deoplete#enable_at_startup = 1
filetype plugin indent on

let makeprg = 'ssh -AT kirr@rtline1.sas.yp-c.yandex.net "(cd arcadia && ./ya make -r rtline/frontend)" 2>&1 | sed "s/\/home\/kirr/\/Users\/kirr\/yandex/g"'

" Remember last location in file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal g'\"" | endif
endif

nmap <silent> <Leader>h :FSHere<cr>

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
set cindent
set expandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4

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
nnoremap <Leader>bl :let @*='breakpoint set --file '.expand("%:t").' --line '.line(".")<cr>:echo "Copied file lldb breakpoint command"<cr>
nnoremap <Leader>br :let @*='break '.@%.':'.line(".")<cr>:echo "Copied file gdb breakpoint command"<cr>
nnoremap <Leader>ca :let @*='https://a.yandex-team.ru/arc/trunk/arcadia/'.expand("%").'#'.line(".")<cr>:echo "Copied arcadia file link to clipboaard"<cr>
"nnoremap y "+y
"vnoremap y "+y
set splitbelow
set splitright

let g:asyncrun_open = 8
nnoremap <leader>ff :AsyncRun! rg --files -g "*<C-r><C-w>*"
nnoremap <leader>S :AsyncStop<CR>
nnoremap <leader>G :Rg <CR>
nnoremap <leader>rg :GrepperRg -Sn <C-r><C-w> -tcpp
nnoremap <leader>rp :GrepperRg -Sn <C-r><C-w> -tpy
nnoremap <leader>F :Files<CR>
nnoremap <leader>B :Buffers<CR>
nnoremap <leader>L :Lines<CR>
nnoremap <leader>pr :!~/tools/show_pull_request.sh <cword><cr>
vnoremap <leader>bl <esc>:let line_start=line("'<") \| let line_end=line("'>") \| execute("AsyncRun!! git blame -L ".line_start.",".line_end." %")<cr>
nnoremap <leader>bl <esc>:let line_start=line(".") \| execute("AsyncRun! git blame -L ".line_start.",".line_start." %")<cr>
"nnoremap <leader>L :let cur_line=line(".") \| execute("!python ~/tools/open_line_in_browser.py '%:p' ".cur_line)<cr>

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

nnoremap <leader>cpr :call <SID>insert_copyright()<CR>
"nnoremap <F8> :call <SID>openFileInWindowAbove()<CR>

set rtp+=/usr/local/opt/fzf

command! YaMakeRemote execute 'AsyncRun ssh -AT kirr@rtline1.sas.yp-c.yandex.net "(cd arcadia_hg && ./ya make -r rtline/frontend)" 2>&1 | sed "s/\/home\/kirr/\/Users\/kirr\/yandex/g"'
command! YaMakeRemoteDebug execute 'AsyncRun ssh -AT kirr@rtline1.sas.yp-c.yandex.net "(cd arcadia_hg && ./ya make rtline/frontend)" 2>&1 | sed "s/\/home\/kirr/\/Users\/kirr\/yandex/g"'

map <C-K> :py3f /usr/local/Cellar/clang-format/2019-01-18/share/clang/clang-format.py<cr>
imap <C-K> <c-o>:py3f /usr/local/Cellar/clang-format/2019-01-18/share/clang/clang-format.py<cr>
command! FormatDiff enew | r !format-diff
command! FormatFile execute '!yhg diff -r default -U0 --color=never % | python /usr/local/Cellar/clang-format/2019-01-18/share/clang/clang-format-diff.py -p1'

autocmd FileType python setlocal shiftwidth=4 softtabstop=4 expandtab
autocmd FileType javascript setlocal shiftwidth=2 softtabstop=2 expandtab
