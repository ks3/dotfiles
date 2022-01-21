set nocompatible

source ~/.vim/vim-plug.vim

filetype indent plugin on

set backspace=indent,start
set expandtab
set laststatus=2
set noshowmode
set number
set path=**,./**
set ruler
set shiftwidth=4
set softtabstop=4
set tabstop=8
set wildmode=list:longest,full

syntax on
colorscheme nord

augroup mail
  autocmd!
  autocmd FileType mail setlocal formatoptions+=anw
augroup end

augroup templates
  autocmd!
  autocmd BufNewFile *.html r ~/Documents/Resources/Templates/html | 1d
  autocmd BufNewFile *.php 0r ~/Documents/Resources/Templates/php | $d
  autocmd BufNewFile *.pl 0r ~/Documents/Resources/Templates/pl | $d
  autocmd BufNewFile *.py 0r ~/Documents/Resources/Templates/py | $d
  autocmd BufNewFile *.sh 0r ~/Documents/Resources/Templates/sh | $d
augroup end

""" settings for ale
let g:ale_puppet_puppetlint_options='--no-autoloader_layout-check --no-2sp_soft_tabs-check --no-arrow_alignment-check'
"let g:ale_linters = { 'yaml': ['cfn-lint'] }
let g:ale_linter_aliases = { 'yaml': ['cloudformation', 'yaml'] }

""" settings for vim-airline
let g:airline#extensions#tabline#enabled=1
let g:airline_powerline_fonts=1
let g:airline_skip_empty_sections=1

" settings for netrw
let g:netrw_banner=0
let g:netrw_liststyle=3
