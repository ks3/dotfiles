set guioptions-=m
set guioptions-=T
set guioptions-=l
set guioptions-=L
set guioptions-=r
set guioptions-=R

if has("gui_macvim")

    set guifont=IntelOneMono-Regular:h12
    "set guifont=HackNFM-Regular:h12
    "let g:NERDTreeGitStatusUseNerdFonts = 1

    augroup AutoDark
        autocmd!
        autocmd OSAppearanceChanged * call SetBackground()
    augroup END

    set transparency=15

else
    set guifont=Source\ Code\ Pro\ 10
endif

set showtabline=0
set lines=50
set columns=160

if filereadable(expand("~/.local/gvimrc"))
    source ~/.local/gvimrc
endif


