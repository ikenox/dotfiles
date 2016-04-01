syntax on
colorscheme desert

set number

set tabstop=4
set autoindent
set expandtab
set shiftwidth=4

nnoremap <silent><C-e> :NERDTreeToggle<CR>

if has('vim_starting')
   " 初回起動時のみruntimepathにneobundleのパスを指定する
   set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" NeoBundleを初期化
call neobundle#begin(expand('~/.vim/bundle/'))

" インストールするプラグインをここに記述
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/vimfiler'
NeoBundle 'justmao945/vim-clang'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'Townk/vim-autoclose'
NeoBundle 'mattn/emmet-vim'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'grep.vim'

call neobundle#end()

" NeoBundleCheck を走らせ起動時に未インストールプラグインをインストールする
NeoBundleCheck

" ファイルタイプ別のプラグイン/インデントを有効にする
filetype plugin indent on

