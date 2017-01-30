"#################################
" Plugins
"#################################

call plug#begin('~/.vim/plug')

Plug 'tpope/vim-surround'

Plug 'Shougo/unite.vim'
"スペースキーとaキーでカレントディレクトリを表示
nnoremap <silent> <Leader>a :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
"スペースキーとfキーでバッファと最近開いたファイル一覧を表示
nnoremap <silent> <Leader>f :<C-u>Unite<Space>buffer file_mru<CR>
"スペースキーとdキーで最近開いたディレクトリを表示
nnoremap <silent> <Leader>d :<C-u>Unite<Space>directory_mru<CR>
"スペースキーとbキーでバッファを表示
nnoremap <silent> <Leader>b :<C-u>Unite<Space>buffer<CR>
"スペースキーとrキーでレジストリを表示
nnoremap <silent> <Leader>r :<C-u>Unite<Space>register<CR>
"スペースキーとtキーでタブを表示
nnoremap <silent> <Leader>t :<C-u>Unite<Space>tab<CR>
"スペースキーとhキーでヒストリ/ヤンクを表示
nnoremap <silent> <Leader>h :<C-u>Unite<Space>history/yank<CR>

Plug 'haya14busa/incsearch.vim'
map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)

call plug#end()


"#################################
" Basic settings
"#################################

" 
syntax enable
set cursorline
set number

" search settings
set hlsearch
set smartcase
set incsearch

set showmatch 

set list           " 不可視文字を表示
set listchars=tab:▸\ ,eol:↲,extends:❯,precedes:❮    " 不可視文字の表示記号指定

set mouse=a

set clipboard=unnamed, autoselect

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

"#################################
" autocmd
"#################################

" indent settings
autocmd FileType json setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType yaml setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType yml  setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType xml  setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType sh   setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType zsh  setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType rb   setlocal shiftwidth=2 tabstop=2 softtabstop=2

"
augroup vimrc-checktime
  autocmd!
  autocmd WinEnter * checktime
augroup END

"#################################
" Color settings
"#################################

set background=dark
colorscheme hybrid

"
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

" highlights
hi MatchParen term=standout ctermbg=blue ctermfg=white
hi SpellBad ctermbg=Red
hi SpellCap ctermbg=Yellow

"#################################
" Keymaps
"#################################

let mapleader = "\<Space>"

" 
nnoremap <silent> L $
vnoremap <silent> L $
nnoremap <silent> H ^
vnoremap <silent> H ^
nnoremap <silent> Y v$y
vnoremap <silent> Y $y

"" insertモードを抜ける
inoremap <silent> jf <ESC>

" ノーマルモード時にセミコロンでコロンを代用
noremap ; :
noremap : ;

" ESC連打でハイライト解除
nmap <Esc><Esc> :nohlsearch<CR><Esc>

"カーソルを表示行で移動
"物理行移動は<C-n>,<C-p>
nnoremap j gj
nnoremap k gk
nnoremap <Down> gj
nnoremap <Up>   gk

" not yank x
nnoremap x "_x
vnoremap x "_x

" ¥ to backslash
inoremap ¥ \

" http://qiita.com/tekkoc/items/98adcadfa4bdc8b5a6ca
nnoremap s <Nop>
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sh <C-w>h
nnoremap sn gt
nnoremap sp gT
nnoremap st :<C-u>tabnew<CR>
nnoremap ss :<C-u>sp<CR>
nnoremap sv :<C-u>vs<CR>
nnoremap sw :w<CR>
nnoremap sq :q<CR>
nnoremap sW :wq<CR>

" arrow
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
imap <ESC>OA <Up>
imap <ESC>OB <Down>
imap <ESC>OC <Right>
imap <ESC>OD <Left>

" insert new line
inoremap <C-o> <esc>o
nnoremap <silent> <CR> o<Esc>

"#################################
" Others
"#################################

" ideaVim-specific settings
try
    set surround
catch
endtry
