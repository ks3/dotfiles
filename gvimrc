set guioptions-=m
set guioptions-=T
set guioptions-=l
set guioptions-=L
set guioptions-=r
set guioptions-=R

if has("gui_macvim")
    set guifont=Source\ Code\ Pro:h12
    set transparency=5
else
    set guifont=Source\ Code\ Pro\ 10
endif

set showtabline=0
set lines=50
set columns=160

if filereadable(expand("~/.local/gvimrc"))
    source ~/.local/gvimrc
endif
