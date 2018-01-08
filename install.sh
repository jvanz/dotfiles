#! /bin/bash

dirname=$(dirname $(readlink -f $0))

sudo dnf update -y
sudo dnf install -y vim tmux powerline tmux-powerline docker ninja-build gyp \
	gcc-c++ gtest-devel gnome-tweak-tool ctags doxygen git-email clang

# install default python packages
pip install --user powerline-status

pip3 install --user meson

rm -f $HOME/{.vim,.gitconfig,.tmux.conf,.fedora.conf}

ln -s $dirname/.vim $HOME/.vim
ln -s $dirname/.gitconfig $HOME/.gitconfig
ln -s $dirname/tmux/.tmux.conf $HOME/.tmux.conf

echo "source $dirname/.bashrc" >> $HOME/.bashrc
