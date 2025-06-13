set nocompatible

source ~/.vim/vim-plug.vim

filetype indent plugin on

set backspace=indent,start
set breakindent
"set breakindentopt+=shift:8
"set breakindentopt+=sbr
"set showbreak='>\ '
let &showbreak='↳   '
set cpoptions+=n
set directory=~/tmp//,.
set expandtab
"set formatoptions+=l
set laststatus=2
set linebreak
set modeline
set nofixendofline
set noshowmode
set number
set path=**,./**
set ruler
set shiftwidth=4
set softtabstop=4
set tabstop=8
set wildmode=list:longest,full
set termguicolors
"set fillchars=vert:|,fold:-,eob:~,lastline:@
set splitbelow

function! SetBackground()
    let interface_style = trim(system("defaults read -g AppleInterfaceStyle"))
    if interface_style == "Dark"
        colorscheme catppuccin_mocha
        "let g:airline_theme = 'catppuccin_mocha'
    else
        colorscheme catppuccin_frappe
        "colorscheme catppuccin_latte
        "let g:airline_theme = 'catppucin_latte'
    endif
    highlight! link VertSplit Pmenu
    redraw!
endfunction

"augroup colors
"    autocmd!
"    autocmd ColorScheme * highlight NonText ctermbg=NONE
"    autocmd ColorScheme * highlight Normal ctermbg=NONE
"    autocmd ColorScheme * highlight LineNr ctermbg=NONE
"augroup end

syntax on
"colorscheme nord
"colorscheme quiet
"colorscheme macvim
"colorscheme catppuccin_mocha
call SetBackground()
"colorscheme PaperColor
"colorscheme catppuccin_mocha

augroup mail
  autocmd!
  autocmd FileType mail setlocal formatoptions+=anw
augroup end

augroup templates
  autocmd!
  autocmd BufNewFile *.html r ~/Documents/Resources/Templates/html.txt | 1d
  autocmd BufNewFile *.php 0r ~/Documents/Resources/Templates/php.txt | $d
  autocmd BufNewFile *.pl 0r ~/Documents/Resources/Templates/pl.txt | $d
  autocmd BufNewFile *.py 0r ~/Documents/Resources/Templates/py.txt | $d
  autocmd BufNewFile *.sh 0r ~/Documents/Resources/Templates/sh.txt | $d
augroup end

""" settings for ale
if filereadable('/opt/macports/bin/tidy')
    let g:ale_html_tidy_executable = '/opt/macports/bin/tidy'
endif
let g:ale_puppet_puppetlint_options='--no-autoloader_layout-check --no-2sp_soft_tabs-check --no-arrow_alignment-check'

""" settings for vim-airline
"let g:airline#extensions#tabline#enabled=1
let g:airline_powerline_fonts=0
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.linenr = ' '
let g:airline_symbols.colnr = ' '
let g:airline_skip_empty_sections=1
"let g:airline_theme='minimalist'
"let g:airline_theme='distinguished'

" settings for netrw
let g:netrw_banner=0
let g:netrw_liststyle=3

"if executable('rg')
"  let g:ctrlp_user_command = 'rg %s --files --hidden --color=never --glob ""'
"endif
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_show_hidden = 1

let g:is_posix=1

set fillchars+=vert:\ 

let g:NERDTreeWinSize=45
let g:NERDTreeGitStatusConcealBrackets = 1
"let g:NERDTreeGitStatusUseNerdFonts = 1
let g:NERDTreeGitStatusIndicatorMapCustom = {
                \ 'Modified'  :'✹',
                \ 'Staged'    :'✚',
                \ 'Untracked' :'✭',
                \ 'Renamed'   :'➜',
                \ 'Unmerged'  :'═',
                \ 'Deleted'   :'✖',
                \ 'Dirty'     :'✗',
                \ 'Ignored'   :'☒',
                \ 'Clean'     :'✔︎',
                \ 'Unknown'   :'?',
                \ }
"autocmd FileType nerdtree setlocal fillchars=vert:|,fold:-,eob:\ ,lastline:@
autocmd FileType nerdtree setlocal fillchars+=eob:\ 

nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" Start NERDTree. If a file is specified, move the cursor to its window.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * NERDTree | if argc() > 0 || exists("s:std_in") | wincmd p | endif
" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | call feedkeys(":quit\<CR>:\<BS>") | endif
