

GIT_USER_CONFIG := $(HOME)/.gitconfig_user
USERNAME := José Guilherme Vanz
EMAIL := jvanz@jvanz.com
SIGKEY := 4159E08B20565EF1
GIT_SUSE_CONFIG := $(HOME)/.gitconfig_suse
BACKUP_DIR ?= $(PWD)/backup
FONTS_DIR ?= $(HOME)/.local/share/fonts
BIN_DIR ?= $(HOME)/.local/bin


all: install reconfigure

reconfigure: uninstall links config
	sudo gpasswd -a $(USER) docker
	sudo usermod -a -G libvirt $(USER)

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
		docker \
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
		k9s \
		libvirt-client \
		make \
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
	flatpak install --user --app -y Obsidian \
		Zotero \
		com.discordapp.Discord \
		Slack \
		com.dropbox.Client \
		com.brave.Browser \
		org.chromium.Chromium \
		com.todoist.Todoist \
		org.mozilla.Thunderbird

.PHONY: install-others
install-others: 
	pip3 install --user yq pynvim

install: zypper-packages flatpak-apps vim install-others

install-oh-my-zsh:
	curl -fsSL --output /tmp/zsh-install.sh  https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
	chmod +x /tmp/zsh-install.sh
	- rm -rf $(HOME)/.oh-my-zsh
	- rm -rf $(HOME)/.zshrc*
	/tmp/zsh-install.sh --keep-zshrc


.PHONY: oh-my-zsh
oh-my-zsh: install-oh-my-zsh
	
$(HOME)/.oh-my-zsh/custom/themes/powerlevel10k:
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $(HOME)/.oh-my-zsh/custom/themes/powerlevel10k

$(HOME)/.oh-my-zsh/custom/plugins/zsh-autosuggestions:
	git clone https://github.com/zsh-users/zsh-autosuggestions $(HOME)/.oh-my-zsh/custom/plugins/zsh-autosuggestions

.PHONY: oh-my-zsh-plugins
oh-my-zsh-plugins: $(HOME)/.oh-my-zsh/custom/themes/powerlevel10k $(HOME)/.oh-my-zsh/custom/plugins/zsh-autosuggestions
	@echo "oh-my-zsh-plugins installed"

.PHONY: rust
rust:
	curl --proto '=https' --tlsv1.2 -sSf --output /tmp/rustup.sh https://sh.rustup.rs
	chmod +x /tmp/rustup.sh
	/tmp/rustup.sh -y
	source "$(HOME)/.cargo/env"
	cargo install cargo-generate

links:
	ln -s -f $(PWD)/tmux.conf $(HOME)/.tmux.conf
	ln -s -f $(PWD)/gitconfig $(HOME)/.gitconfig
	ln -s -f $(PWD)/zshrc ~/.zshrc

$(BIN_DIR)/nvim:
	curl -L -o /tmp/nvim.appimage https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
	chmod u+x /tmp/nvim.appimage
	cp /tmp/nvim.appimage $@

.PHONY: vim
vim: $(BIN_DIR)/nvim
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


/tmp/0xProto.tar.xz:
	curl -fLo "/tmp/0xProto.tar.xz" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.0/0xProto.tar.xz
	tar -C /tmp -xvf /tmp/0xProto.tar.xz

$(FONTS_DIR):
	mkdir ~/.local/share/fonts/

.PHONY: fonts
fonts: /tmp/0xProto.tar.xz $(FONTS_DIR)
	mv /tmp/0xProtoNerdFontMono-Regular.ttf  ~/.local/share/fonts/
	mv /tmp/0xProtoNerdFontPropo-Regular.ttf  ~/.local/share/fonts/
	mv /tmp/0xProtoNerdFont-Regular.ttf  ~/.local/share/fonts/
	fc-cache -f -v

.PHONY: generate-backup
generate-backup:
	gpg -a --export > mypubkeys.asc
	gpg -a --export-secret-keys > myprivatekeys.asc
	gpg --export-ownertrust > otrust.txt
	cp $(HOME)/.ssh ssh
	tar -cvf gpgkeys.tar mypubkeys.asc myprivatekeys.asc otrust.txt ssh

.PHONY: restore-backup
restore-backup:
	tar -xvf gpgkeys.tar
	cp ssh/* $(HOME)/.ssh/
	chmod 600 $(HOME)/.ssh/*
	gpg --import myprivatekeys.asc
	gpg --import mypubkeys.asc
	gpg --import-ownertrust otrust.txt
	gpg -K
	gpg -k
