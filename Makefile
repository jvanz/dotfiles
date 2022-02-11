

GIT_USER_CONFIG := $(HOME)/.gitconfig_user
USERNAME := José Guilherme Vanz
EMAIL := jvanz@jvanz.com
SIGKEY := 4159E08B20565EF1
GIT_SUSE_CONFIG := $(HOME)/.gitconfig_suse

all: install reconfigure

reconfigure: uninstall create-user-systemd-dir links config 

uninstall: 
	rm -f ~/.tmux.conf
	rm -f ~/$(GIT_USER_CONFIG)
	rm -f ~/.gitconfig
	rm -f ~/.config/osc
	rm -f ~/.zshrc
	rm -f ~/.zsh

install: 
	sudo zypper install -y \
		anki \
		autoconf \
		automake \
		clang \
		ctags \
		curl \
		deja-dup \
		doxygen \
		flatpak \
		gcc \
		gcc-c++ \
		gdb \
		git-core \
		git-email \
		go \
		golang-packaging \
		jq \
		make \
		meson \
		neovim \
		ninja \
		osc \
		podman \
		python-pip \
		python3-docker-compose \
		python3-pip \
		quilt \
		secret-tool \
		strace \
		texlive-dvisvgm \
		tmux \
		unzip \
		valgrind \
		vim \
		virt-install \
		wget \
		zsh
	
	pip3 install --user meson

links:
	ln -s -f $(PWD)/tmux.conf $(HOME)/.tmux.conf
	ln -s -f $(PWD)/gitconfig $(HOME)/.gitconfig
	ln -s -f $(PWD)/osc ~/.config/osc
	ln -s -f $(PWD)/zshrc ~/.zshrc
	ln -s -f $(PWD)/vim ~/.config/nvim

git-config: 
	# Configure git
	git config -f $(GIT_USER_CONFIG) user.name "$(USERNAME)"
	git config -f $(GIT_USER_CONFIG) user.email "$(EMAIL)"
	git config -f $(GIT_USER_CONFIG) user.signingkey "$(SIGKEY)"
	git config -f $(GIT_USER_CONFIG) commit.gpgsign true
	ln -s -f $(PWD)/gitconfig.suse $(GIT_SUSE_CONFIG) 

bash-config:
	echo "source $(PWD)/bashrc" >> $(HOME)/.bashrc

gnome-config:
	# Configure gnome
	gsettings set org.gnome.shell.app-switcher current-workspace-only true

config: bash-config git-config gnome-config


systemd-reload-daemon:
	systemctl --user daemon-reload

create-user-systemd-dir:
	mkdir -p  ~/.config/systemd/user

