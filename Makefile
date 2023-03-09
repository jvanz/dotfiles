

GIT_USER_CONFIG := $(HOME)/.gitconfig_user
USERNAME := José Guilherme Vanz
EMAIL := jvanz@jvanz.com
SIGKEY := 4159E08B20565EF1
GIT_SUSE_CONFIG := $(HOME)/.gitconfig_suse
BACKUP_DIR ?= $(PWD)/backup

SERVICE_NAME=sync_brain
SYSTEMD_SERVICE_FILE_DIR ?= $(HOME)/.config/systemd/user

all: install reconfigure

reconfigure: uninstall links config

uninstall: 
	rm -f ~/.tmux.conf rm -f ~/$(GIT_USER_CONFIG)
	rm -f ~/.gitconfig
	rm -f ~/.config/osc

zypper-packages:
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
		helm \
		jq \
		make \
		neovim \
		ninja \
		osc \
		podman \
		quilt \
		secret-tool \
		strace \
		tmux \
		unzip \
		valgrind \
		vim \
		virt-install \
		wget \
		zsh

.PHONY: flatpak-apps
flatpak-apps:
	flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak install --user --app -y Obsidian Zotero com.discordapp.Discord Slack

.PHONY: install-others
install-others: 
	pip3 install --user yq

install: zypper-packages flatpak-apps install-others

.PHONY: oh-my-zsh
oh-my-zsh:
	curl -fsSL --output /tmp/zsh-install.sh  https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
	chmod +x /tmp/zsh-install.sh
	- rm -rf $(HOME)/.oh-my-zsh
	- rm -rf $(HOME)/.zshrc*
	/tmp/zsh-install.sh --keep-zshrc
	
.PHONY: oh-my-zsh-plugins
oh-my-zsh-plugins:
	echo "Installing zsh plugins"
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $(HOME)/.oh-my-zsh/custom/themes/powerlevel10k
	git clone https://github.com/zsh-users/zsh-autosuggestions $(HOME)/.oh-my-zsh/custom/plugins/zsh-autosuggestions

links:
	ln -s -f $(PWD)/tmux.conf $(HOME)/.tmux.conf
	ln -s -f $(PWD)/gitconfig $(HOME)/.gitconfig
	ln -s -f $(PWD)/osc ~/.config/osc
	ln -s -f $(PWD)/vim ~/.config/nvim
	ln -s -f $(PWD)/zshrc ~/.zshrc

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

.PHONY: restore-backup
restore-backup:
	cp $(BACKUP_DIR)/ssh/* $(HOME)/.ssh/
	chmod 600 $(HOME)/.ssh/id_rsa*
