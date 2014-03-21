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

set guifont=PragmataPro


set list listchars=tab:>·,trail:·

set nowrap
set autoindent
set smartindent
set expandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4

vnoremap < <gv
vnoremap > >gv

set pastetoggle=<leader>v


"Solarized
set t_Co=16
if has("gui_running")
    set t_Co=256
    let g:solarized_termcolors=256
    set guifont=Menlo\ Regular:h13
    colorscheme solarized
    set transparency=4
endif

syntax enable
"set background=dark
"colorscheme solarized

"call togglebg#map("<leader>b")

"Lucius
"let g:lucius_style='light'
"let g:lucius_contrast='high'
"let g:lucius_contrast_bg='high'
"colorscheme lucius

"Hemisu
"colorscheme hemisu

hi LineNr ctermfg=grey

" NERDTree
nmap <leader>nt :NERDTreeFind<CR>
let NERDTreeShowBookmarks=1
let NERDTreeChDirMode=0
let NERDTreeQuitOnOpen=1
let NERDTreeShowHidden=1
let NERDTreeKeepTreeInNewTab=1

let g:alternateSearchPath='wdr:src'
"let g:ackprg='ack --nocolor --nogroup --column'

" Unite
let g:unite_split_rule='botright'
let g:unite_source_rec_max_cache_files=10000000
let g:unite_enable_start_insert = 1
" Use ag for search
if executable('ag')
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
  let g:unite_source_grep_recursive_opt = ''
endif
call unite#filters#matcher_default#use(['matcher_fuzzy'])
call unite#filters#sorter_default#use(['sorter_rank'])
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
try
  " Set up some custom ignores
  call unite#custom#source('buffer,file,file_rec/async,file_rec,file_mru,file,grep',
      \ 'ignore_pattern', join([
      \ '\.git/',
      \ '\.hg/',
      \ '\.tox',
      \ '\.idea',
      \ '\.pyc',
      \ '\.o',
      \ '__pycache__',
      \ '_build',
      \ 'dist',
      \ '\.tar\.gz',
      \ '\.mp3',
      \ '\.xml',
      \ '\.zip',
      \ '\.java',
      \ '\.jar',
      \ '\.png',
      \ '\.sass-cache/',
      \ '*/out/',
      \ ], '\|'))
catch
endtry

command W w
command WQ wq
command Wq wq
command Q q
