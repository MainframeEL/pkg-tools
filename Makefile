.PHONY: all

all: .go-setup src/sunmockgen srpmproc/srpmproc modulelist

.dnf:
	sudo dnf -y install epel-release
	sudo dnf -y groupinstall "Development Tools"
	sudo dnf -y install golang mock nginx createrepo git
	touch .dnf

.system:
	sudo dnf config-manager --set-enabled powertools
	sudo systemctl start nginx
	sudo systemctl enable nginx
	touch .system

.go-setup:
	go get gopkg.in/yaml.v2
	touch .go-setup
	

srpmproc:
	git clone https://github.com/SunOS-Linux/srpmproc.git


srpmproc/srpmproc: srpmproc
	cd srpmproc; CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build ./cmd/srpmproc


src/sunmockgen:
	go build -o src/sunmockgen src/sunmockgen.go

modulelist:
	for i in modulefiles/*; do echo "Building list of modular packages: $$i"; go run src/sunrpmmodules.go < $$i >> modulelist; done

install: srpmproc/srpmproc src/sunmockgen modulelist .dnf .system
	mkdir -p /etc/sun/devtools
	cp -r etc_mock/sunos* /etc/mock/
	cp -r modulefiles /etc/sun/devtools/
	install -m 755 src/sunmockgen /usr/local/bin/
	install -m 755 srpmproc/srpmproc /usr/local/bin/
	install -m 755 bin/* /usr/local/bin/
	install -m 644 modulelist /etc/sun/devtools/
	test -d /usr/share/nginx/html/repo || mkdir /usr/share/nginx/html/repo
	chmod 777 /usr/share/nginx/html/repo


clean:
	rm -rf srpmproc modulelist src/sunmockgen

# enable makefile to accept argument after command
#https://stackoverflow.com/questions/6273608/how-to-pass-argument-to-makefile-from-command-line

args = `arg="$(filter-out $@,$(MAKECMDGOALS))" && echo $${arg:-${1}}`
%:
	@:
status:
	git status
commit:
	git commit -am "$(call args, Automated commit message without details, Please read the git diff)"  && git push
pull:
	git pull
help:
	@echo "Usage: make <target> <argument>"
	@echo
	@echo "Available targets are:"
	@echo "  all                    Default without argument"
	@echo "  help                   Showing this help "
	@echo "  install                Install devtool"
	@echo "  build  rpm-name        Ex: make build perl "
	@echo "  clean                  clean myrocky and srpmproc "
	@echo "  commit {"my message"}  ie, git commit, without or with real commit message"
	@echo "  status                 ie, git status"
	@echo "  pull                   ie, git pull"
	@echo ""

build:
	(mkdir -p $(HOME)/sun && cd $(HOME)/sun && sunget $(filter-out $@,$(MAKECMDGOALS)))
	(cd $(HOME)/sun/$(filter-out $@,$(MAKECMDGOALS))/r8 && sunbuild-notest)




