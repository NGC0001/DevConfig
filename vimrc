" Pathogen
" https://github.com/tpope/vim-pathogen
" https://gist.github.com/romainl/9970697
execute pathogen#infect()
filetype plugin indent on
syntax on

" Refer to https://www.shortcutfoo.com/blog/top-50-vim-configuration-options/
" for some common vim configurations.

set tabstop=4           " Witdth of \t in documents.
set softtabstop=4       " Withth of entered <tab>.
set expandtab           " Transform entered <Tab> into space characters.
autocmd BufNewFile,BufRead GNUmakefile,makefile,Makefile set noexpandtab
set autoindent
set smartindent
set shiftwidth=4        " Number of space characters inserted for indentation.

set hlsearch
set incsearch         " Incremental search
" set ignorecase        " Do case insensitive matching
" set smartcase         " Do smart case matching

" set autowrite         " Automatically save before commands like :next and :make
" set hidden            " Hide buffers when they are abandoned

" set noerrorbells      " Disable beep on errors.
" set visualbell        " Flash the screen instead of beeping on errors.
set title
" set laststatus=2      " Always display the status bar.
set showcmd           " Show (partial) command in status line.
set wildmenu          " Display command line's tab complete options as a menu.
set ruler             " Always show cursor position.
set number
set relativenumber
" set cursorline        " Highlight the line currently under cursor.
" set cursorcolumn      " Highlight the column currently under cursor.
set colorcolumn=80
" highlight ColorColumn ctermbg=lightcyan guibg=blue
highlight Comment ctermfg=blue
set showmatch         " Show matching brackets.
" set background=dark
" set colorscheme wombat256mod
" set mouse=a           " Enable mouse usage (all modes)

" Have Vim jump to the last position when reopening a file.
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" vim-plug
" https://github.com/junegunn/vim-plug
" https://jdhao.github.io/2018/12/24/centos_nvim_install_use_guide_en/
" --------------------------------
" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')
Plug 'preservim/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'preservim/nerdcommenter'
Plug 'tomtom/tcomment_vim'
call plug#end()

" NERDTree configuration.
" https://github.com/preservim/nerdtree
" https://jdhao.github.io/2018/09/10/nerdtree_usage/
map <C-n> :NERDTreeToggle<CR>

" NERD Commenter configuration.
" https://github.com/preservim/nerdcommenter
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
" " Set a language to use its alternate delimiters by default
" let g:NERDAltDelims_java = 1
" " Add your own custom formats or override the defaults
" let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1
" Enable NERDCommenterToggle to check all selected lines is commented or not 
let g:NERDToggleCheckAllLines = 1
