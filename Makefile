

GIT_USER_CONFIG := $(HOME)/.gitconfig_user
USERNAME := José Guilherme Vanz
EMAIL := jvanz@jvanz.com
SIGKEY := 4159E08B20565EF1
GIT_SUSE_CONFIG := $(HOME)/.gitconfig_suse

RSYNC_SERVICE_NAME := rsync-backup
IMAPFILTER_SERVICE_NAME := imapfilter

all: install reconfigure

reconfigure: uninstall create-user-systemd-dir links config rsync mail

uninstall: clean-rsync clean-imapfilter
	rm -rf ~/.vim
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
		imapfilter \
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
		rsync \
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
	ln -s -f $(PWD)/vim $(HOME)/.vim
	ln -s -f $(PWD)/vim $(HOME)/.config/nvim
	ln -s -f $(PWD)/tmux.conf $(HOME)/.tmux.conf
	ln -s -f $(PWD)/gitconfig $(HOME)/.gitconfig
	ln -s -f $(PWD)/osc ~/.config/osc
	ln -s -f $(PWD)/mbsyncrc ~/.mbsyncrc
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

config: bash-config git gnome-config

clean-rsync:
	rm -f ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).service
	rm -f ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).timer

rsync-service:
	cp $(PWD)/oneshoot-service.service ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).service
	sed -i "s/{{DESCRIPTION}}/Run rsync tool/" ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).service
	sed -i "s/{{DOCUMENTATION}}/man:rsync\(1\)/" ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).service
	sed -i "s;{{WANTEDBY}};default.target;" ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).service
	sed -i "s;{{EXECSTART}};$(shell which rsync) -av --exclude=.cache --exclude=.mozilla --exclude=.local/share/containers $$HOME\/ backupserver:\/home\/$$USER\/;" ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).service

rsync-timer:
	cp $(PWD)/oneshoot-service.timer ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).timer
	sed -i "s/{{DESCRIPTION}}/Rsync timer/" ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).timer
	sed -i "s;{{ONBOOTSEC}};10m;" ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).timer
	sed -i "s;{{ONCALENDAR}};hourly;" ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).timer
	sed -i "s;{{UNIT}};$(RSYNC_SERVICE_NAME).service;" ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).timer
	sed -i "s/{{WANTEDBY}}/default.target/" ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).timer
	systemctl --user enable ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).timer
	systemctl --user start $(RSYNC_SERVICE_NAME).timer

rsync:  clean-rsync rsync-service rsync-timer

systemd-reload-daemon:
	systemctl --user daemon-reload

clean-imapfilter:
	rm -f ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).service
	rm -f ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).timer

imapfilter: clean-imapfilter imapfilter-service imapfilter-timer

imapfilter-service:
	cp $(PWD)/oneshoot-service.service ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).service
	sed -i "s/{{DESCRIPTION}}/Run imapfilter to organize email/" ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).service
	sed -i "s/{{DOCUMENTATION}}/man:imapfilter\(1\)/" ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).service
	sed -i "s;{{EXECSTART}};$(shell which imapfilter);" ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).service
	sed -i "s;{{WANTEDBY}};default.target;" ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).service

imapfilter-timer:
	cp $(PWD)/oneshoot-service.timer ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).timer
	sed -i "s/{{DESCRIPTION}}/Mailbox filtering timer/" ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).timer
	sed -i "s/{{WANTEDBY}}/default.target/" ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).timer
	sed -i "s;{{ONBOOTSEC}};5m;" ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).timer
	sed -i "s;{{ONCALENDAR}};hourly;" ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).timer
	sed -i "s;{{UNIT}};$(IMAPFILTER_SERVICE_NAME).service;" ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).timer
	systemctl --user enable ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).timer
	systemctl --user start $(IMAPFILTER_SERVICE_NAME).timer

create-user-systemd-dir:
	mkdir -p  ~/.config/systemd/user

mail: imapfilter systemd-reload-daemon
