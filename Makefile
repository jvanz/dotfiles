

GIT_USER_CONFIG := $(HOME)/.gitconfig_user
USERNAME := José Guilherme Vanz
EMAIL := jvanz@jvanz.com
SIGKEY := 4159E08B20565EF1

RSYNC_SERVICE_NAME := rsync-backup
IMAPFILTER_SERVICE_NAME := imapfilter
MAILBOX_SERVICE_NAME := mailbox-sync

all: install reconfigure

reconfigure: uninstall create-user-systemd-dir links config rsync mail

uninstall: clean-rsync clean-imapfilter clean-mailbox-sync clean-mutt
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
		neomutt \
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
	ln -s -f $(PWD)/tmux.conf $(HOME)/.tmux.conf
	ln -s -f $(PWD)/gitconfig $(HOME)/.gitconfig
	ln -s -f $(PWD)/osc ~/.config/osc
	ln -s -f $(PWD)/mutt ~/.mutt
	ln -s -f $(PWD)/muttrc ~/.muttrc
	ln -s -f $(PWD)/mbsyncrc ~/.mbsyncrc
	ln -s -f $(PWD)/zshrc ~/.zshrc

clean-mutt:
	rm -rf ~/.mutt
	rm -rf ~/.muttrc

mutt: clean-mutt
	ln -s -f $(PWD)/mutt ~/.mutt
	ln -s -f $(PWD)/muttrc ~/.muttrc

config:
	echo "source $(PWD)/bashrc" >> $(HOME)/.bashrc
	# Configure git
	git config -f $(GIT_USER_CONFIG) user.name "$(USERNAME)"
	git config -f $(GIT_USER_CONFIG) user.email "$(EMAIL)"
	git config -f $(GIT_USER_CONFIG) user.signkey "$(SIGKEY)"
	git config -f $(GIT_USER_CONFIG) commit.gpgsign true

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
	sed -i "/\[Unit\]/a After=$(MAILBOX_SERVICE_NAME).service" ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).service

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

clean-mailbox-sync:
	rm -f ~/.config/systemd/user/$(MAILBOX_SERVICE_NAME).service
	rm -f ~/.config/systemd/user/$(MAILBOX_SERVICE_NAME).timer

mailbox-timer-sync:
	cp $(PWD)/oneshoot-service.timer ~/.config/systemd/user/$(MAILBOX_SERVICE_NAME).timer
	sed -i "s/{{DESCRIPTION}}/Mailboxes synchronization timer/" ~/.config/systemd/user/$(MAILBOX_SERVICE_NAME).timer
	sed -i "s/{{WANTEDBY}}/default.target/" ~/.config/systemd/user/$(MAILBOX_SERVICE_NAME).timer
	sed -i "s;{{ONBOOTSEC}};5m;" ~/.config/systemd/user/$(MAILBOX_SERVICE_NAME).timer
	sed -i "s;{{ONCALENDAR}};hourly;" ~/.config/systemd/user/$(MAILBOX_SERVICE_NAME).timer
	sed -i "s;{{UNIT}};$(MAILBOX_SERVICE_NAME).service;" ~/.config/systemd/user/$(MAILBOX_SERVICE_NAME).timer
	systemctl --user enable ~/.config/systemd/user/$(MAILBOX_SERVICE_NAME).timer
	systemctl --user start $(MAILBOX_SERVICE_NAME).timer

mailbox-service-sync:
	cp $(PWD)/oneshoot-service.service ~/.config/systemd/user/$(MAILBOX_SERVICE_NAME).service
	sed -i "s/{{DESCRIPTION}}/Mailbox synchronization service/" ~/.config/systemd/user/$(MAILBOX_SERVICE_NAME).service
	sed -i "s/{{DOCUMENTATION}}/man:isync\(1\)/" ~/.config/systemd/user/$(MAILBOX_SERVICE_NAME).service
	sed -i "s/{{WANTEDBY}}/mail.target/" ~/.config/systemd/user/$(MAILBOX_SERVICE_NAME).service
	sed -i "s;{{EXECSTART}};$(shell which mbsync) -Va;" ~/.config/systemd/user/$(MAILBOX_SERVICE_NAME).service

mailbox-sync: clean-mailbox-sync mailbox-service-sync mailbox-timer-sync 

mail: mailbox-sync imapfilter systemd-reload-daemon
