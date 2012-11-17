
bindir=	$(HOME)/bin
dotdir= $(HOME)

SCRIPTS= \
    vgunique \
    linkinstall \

DOTFILES= \
    vimrc \
    vim/plugin/cscope.vim \
    vim/plugin/patch.vim \
    vim/plugin/quilt.vim \
    vim/plugin/valgrind.vim \

all: $(SCRIPTS)

TIMESTAMP:=		$(shell date +%Y%m%d)
INSTALL=		install
INSTALL_BACKUP_OPTS=	--backup --suffix=.$(TIMESTAMP).bak
INSTALL_SCRIPT=		$(INSTALL) -m 0755 -D $(INSTALL_BACKUP_OPTS)
INSTALL_DOTFILE=	$(INSTALL) -m 0644 -D $(INSTALL_BACKUP_OPTS)

install: install-scripts install-dotfiles

install-scripts:
	@for file in $(SCRIPTS) ; do \
	    echo "installing $$file" ;\
	    $(INSTALL_SCRIPT) $$file $(DESTDIR)/$(bindir)/$$file ;\
	done

install-dotfiles:
	@for file in $(DOTFILES) ; do \
	    echo "installing $$file" ;\
	    $(INSTALL_DOTFILE) $$file $(DESTDIR)/$(dotdir)/.$$file ;\
	done

diff:
	$(MAKE) INSTALL_SCRIPT="diff -u" INSTALL_DOTFILE="diff -u" install
