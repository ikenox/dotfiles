"================================================================
" Plugins
"================================================================
call plug#begin()

Plug 'w0ng/vim-hybrid'

Plug 'tpope/vim-surround'

Plug 'itchyny/lightline.vim'
"
Plug 'Shougo/unite.vim'
let mapleader = "\<Space>"
let g:unite_enable_start_insert=1
"スペースキーとaキーでカレントディレクトリを表示
nnoremap <silent> <Leader>a :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
"スペースキーとbキーでバッファを表示
nnoremap <silent> <Leader>b :<C-u>Unite<Space>buffer<CR>
"スペースキーとrキーでレジストリを表示
nnoremap <silent> <Leader>r :<C-u>Unite<Space>register<CR>
"スペースキーとtキーでタブを表示
nnoremap <silent> <Leader>t :<C-u>Unite<Space>tab<CR>
"スペースキーとhキーでヒストリ/ヤンクを表示
nnoremap <silent> <Leader>h :<C-u>Unite<Space>history/yank<CR>
" 大文字小文字を区別しない  
let g:unite_enable_ignore_case = 1  
let g:unite_enable_smart_case = 1
" ESCキーを2回押すと終了する  
au FileType unite nnoremap <silent> <buffer> <ESC><ESC> :q<CR>
au FileType unite inoremap <silent> <buffer> <ESC><ESC> <ESC>:q<CR>

" grep検索
nnoremap <silent> ,g  :<C-u>Unite grep:. -buffer-name=search-buffer<CR>

" カーソル位置の単語をgrep検索
nnoremap <silent> ,cg :<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W>

" grep検索結果の再呼出
nnoremap <silent> ,r  :<C-u>UniteResume search-buffer<CR>

" unite grep に ag(The Silver Searcher) を使う
if executable('ag')
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
  let g:unite_source_grep_recursive_opt = ''
endif
"
Plug 'Shougo/neomru.vim'
"スペースキーとdキーで最近開いたディレクトリを表示
nnoremap <silent> <Leader>d :<C-u>Unite<Space>directory_mru<CR>
"スペースキーとfキーでバッファと最近開いたファイル一覧を表示
nnoremap <silent> <Leader>f :<C-u>Unite<Space>buffer file_mru<CR>

Plug 'Shougo/vimproc.vim', {'do' : 'make'}

Plug 'haya14busa/incsearch.vim'
map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)

call plug#end()

"================================================================
" basic settings
"================================================================

" 
syntax enable
set cursorline
set number

set wildmode=longest,full

" search settings
set hlsearch
set smartcase

set showmatch 

set list           " 不可視文字を表示
set listchars=tab:▸\ ,eol:↲,extends:❯,precedes:❮    " 不可視文字の表示記号指定

set mouse=a

set clipboard=unnamed,autoselect

set visualbell

set scrolloff=8                " 上下8行の視界を確保
set sidescrolloff=16           " 左右スクロール時の視界を確保
set sidescroll=1               " 左右スクロールは一文字づつ行う

" indent settings
set autoindent
set smartindent

set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

set splitright
set splitbelow

set showcmd
set showmode
set laststatus=2
set cmdheight=2
set ruler

" file settings
set confirm
set hidden
set autoread
set noswapfile
set nobackup

" allow to create new line in INSERT mode
set bs=start,indent
set backspace=indent,eol,start

" do not stop cursor at an end of line
set whichwrap=b,s,h,l,<,>,[,],~

" change cursor shape when insert mode
if &term =~ "screen"
  let &t_SI = "\eP\e]50;CursorShape=1\x7\e\\"
  let &t_EI = "\eP\e]50;CursorShape=0\x7\e\\"
elseif &term =~ "xterm"
  let &t_SI = "\e]50;CursorShape=1\x7"
  let &t_EI = "\e]50;CursorShape=0\x7"
endif

" indent settings
autocmd FileType json setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType yaml setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType yml  setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType xml  setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType sh   setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType zsh  setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType rb   setlocal shiftwidth=2 tabstop=2 softtabstop=2

" use hard tab when Makefile
let _curfile=expand("%:r")
if _curfile == 'Makefile' || _curfile == 'makefile'
  set noexpandtab
endif

"
augroup vimrc-checktime
  autocmd!
  autocmd WinEnter * checktime
augroup END

"================================================================
" Basic keymaps
"================================================================

source ~/.vimrc.keymap

"================================================================
" Color settings
"================================================================

set background=dark
colorscheme hybrid
"
" highlights
hi MatchParen term=standout ctermbg=blue ctermfg=white
hi SpellBad ctermbg=Red
hi SpellCap ctermbg=Yellow

if &term =~ "xterm-256color" || "screen-256color"
  set t_Co=256
  set t_Sf=[3%dm
  set t_Sb=[4%dm
elseif &term =~ "xterm-debian" || &term =~ "xterm-xfree86"
  set t_Co=16
  set t_Sf=[3%dm
  set t_Sb=[4%dm
elseif &term =~ "xterm-color"
  set t_Co=8
  set t_Sf=[3%dm
  set t_Sb=[4%dm
endif

"================================================================
" Others
"================================================================


