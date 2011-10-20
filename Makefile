
bindir=	$(HOME)/bin
dotdir= $(HOME)

SCRIPTS= \
    patch-normalise-hunk.pl \

DOTFILES= \
    vimrc \
    vimrc.d/cscope.vim \
    vimrc.d/patch.vim \
    vimrc.d/quilt.vim \
    vimrc.d/valgrind.vim \

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

