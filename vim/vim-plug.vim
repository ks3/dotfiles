" ensure plug directory exists
if empty(glob('~/.vim/vim-plug'))
  silent !mkdir -p ~/.vim/vim-plug
endif

" download vim-plug if needed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !mkdir -p ~/.vim/autoload
  silent !curl -Lo ~/.vim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  " source ourselves to get the plugs defined below then install
  source ~/.vim/vim-plug.vim
  silent :PlugInstall
endif


call plug#begin('~/.vim/vim-plug')

" color schemes
Plug 'arcticicestudio/nord-vim'
Plug 'romainl/apprentice'

" airline and themes
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" programming support
Plug 'tpope/vim-fugitive'
Plug 'w0rp/ale'

" puppet
Plug 'rodjek/vim-puppet'

call plug#end()
