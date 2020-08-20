

GIT_USER_CONFIG := $(HOME)/.gitconfig_user
USERNAME := José Guilherme Vanz
EMAIL := jvanz@jvanz.com
SIGKEY := 4159E08B20565EF1

RSYNC_SERVICE_NAME := rsync-backup
IMAPFILTER_SERVICE_NAME := imapfilter

all: uninstall install links config

reconfigure: uninstall links config

uninstall: clean-rsync clean-imapfilter
	rm -rf ~/.vim
	rm -f ~/.tmux.conf
	rm -f ~/$(GIT_USER_CONFIG)
	rm -f ~/.gitconfig

install: 
	sudo zypper install -y \
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
		imapfilter \
		make \
		meson \
		neomutt \
		ninja \
		osc \
		python-pip \
		python3-pip \
		rsync \
		secret-tool \
		strace \
		tmux \
		unzip \
		valgrind \
		vim \
		wget
	
	pip3 install --user meson

links:
	ln -s $(PWD)/vim $(HOME)/.vim
	ln -s $(PWD)/tmux.conf $(HOME)/.tmux.conf
	ln -s $(PWD)/gitconfig $(HOME)/.gitconfig
	ln -s $(PWD)/osc ~/.config/osc

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

rsync:  clean-rsync
	mkdir -p  ~/.config/systemd/user
	cp $(PWD)/oneshoot-service.service ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).service
	cp $(PWD)/oneshoot-service.timer ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).timer
	sed -i "s/{{DESCRIPTION}}/Run rsync tool/" ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).service
	sed -i "s/{{DOCUMENTATION}}/man:rsync\(1\)/" ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).service
	sed -i "s;{{EXECSTART}};$(shell which rsync) -av --exclude=.cache --exclude=.mozilla $$HOME\/ backupserver:\/home\/$$USER\/;" ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).service
	sed -i "s/{{DESCRIPTION}}/Rsync timer/" ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).timer
	sed -i "s;{{ONBOOTSEC}};1m;" ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).timer
	sed -i "s;{{ONCALENDAR}};daily;" ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).timer
	systemctl --user enable ~/.config/systemd/user/$(RSYNC_SERVICE_NAME).timer
	systemctl --user start $(RSYNC_SERVICE_NAME).timer

clean-imapfilter:
	rm -f ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).service
	rm -f ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).timer

imapfilter: clean-imapfilter
	mkdir -p  ~/.config/systemd/user
	cp $(PWD)/oneshoot-service.service ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).service
	cp $(PWD)/oneshoot-service.timer ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).timer
	sed -i "s/{{DESCRIPTION}}/Run imapfilter to organize email/" ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).service
	sed -i "s/{{DOCUMENTATION}}/man:imapfilter\(1\)/" ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).service
	sed -i "s;{{EXECSTART}};$(shell which imapfilter);" ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).service
	sed -i "s/{{DESCRIPTION}}/Imapfilter timer/" ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).timer
	sed -i "s;{{ONBOOTSEC}};1m;" ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).timer
	sed -i "s;{{ONCALENDAR}};daily 12:00:00;" ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).timer
	sed -i "/OnCalendar=daily 12:00:00/a OnCalendar=daily 18:00:00" ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).timer
	systemctl --user enable ~/.config/systemd/user/$(IMAPFILTER_SERVICE_NAME).timer
	systemctl --user start $(IMAPFILTER_SERVICE_NAME).timer

