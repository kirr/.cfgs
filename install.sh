DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

ln -s $DIR/.vimrc ~/.vimrc
ln -s $DIR/.vim ~/.vim
ln -s $DIR/.tmux.conf ~/.tmux.conf
ln -s $DIR/.zshrc ~/.zshrc

sudo apt-get install tmux
sudo apt-get install zsh
sudo apt-get install vim

curl -L git.io/antigen > ~/antigen.zsh

git clone https://github.com/lifepillar/vim-solarized8.git \
        ~/.vim/pack/themes/opt/solarized8
