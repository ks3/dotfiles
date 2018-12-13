set nocompatible

source ~/.vim/vim-plug.vim

autocmd FileType mail setlocal formatoptions+=anw
filetype indent plugin on

set backspace=indent,start
set expandtab
set laststatus=2
set number
set path=**,./**
set ruler
set shiftwidth=4
set softtabstop=4
set tabstop=4
set wildmode=list:longest,full

syntax on
colorscheme apprentice

""" settings for ale
let g:ale_puppet_puppetlint_options='--no-autoloader_layout-check --no-2sp_soft_tabs-check --no-arrow_alignment-check'

""" settings for vim-airline
let g:airline#extensions#tabline#enabled=1
let g:airline_theme="bubblegum"
let g:airline_powerline_fonts=1
let g:airline_skip_empty_sections=1

" settings for netrw
let g:netrw_banner=0
let g:netrw_liststyle=3
