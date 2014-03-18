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

" CtrlP
let g:ctrlp_max_files=0
let g:ctrlp_custom_ignore={
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|o|png)$',
  \ } 
set wildignore +=*/tmp/*,*.so,*.swp,*.zip,*/.git/*,*.o
"let g:ctrlp_user_command = 'find %s -type f'

let g:alternateSearchPath='wdr:src'
"let g:ackprg='ack --nocolor --nogroup --column'

command W w
command WQ wq
command Wq wq
command Q q
