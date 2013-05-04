
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

# External vim modules
VIM_MODULES= \
    markdown \

URL_markdown= https://github.com/plasticboy/vim-markdown/archive/master.tar.gz

VIM_SUBDIRS= ftdetect after syntax plugin

all: $(SCRIPTS)

TIMESTAMP:=		$(shell date +%Y%m%d)
INSTALL=		install
INSTALL_BACKUP_OPTS=	--backup --suffix=.$(TIMESTAMP).bak
INSTALL_SCRIPT=		$(INSTALL) -m 0755 -D $(INSTALL_BACKUP_OPTS)
INSTALL_DOTFILE=	$(INSTALL) -m 0644 -D $(INSTALL_BACKUP_OPTS)

all: $(foreach m,$(VIM_MODULES),vimmods/$m/.build-stamp)

vimmods/%/.build-stamp:
	mkdir -p $(@D)
	cd $(@D) ; wget -O - $(URL_$*) | tar -xvzf - --strip 1
	touch $@

clean:
	$(RM) -r $(foreach m,vimmods/$m,$(VIM_MODULES))

install: all install-scripts install-dotfiles install-vim-modules

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

install-vim-modules:
	@for mod in $(VIM_MODULES) ; do \
	    for file in `cd vimmods/$$mod; find $(VIM_SUBDIRS) -type f 2>/dev/null` ; do \
		echo "installing vimmods/$$mod/$$file" ;\
		$(INSTALL_DOTFILE) vimmods/$$mod/$$file $(DESTDIR)/$(dotdir)/vim/$$file ;\
	    done ;\
	done

diff:
	$(MAKE) INSTALL_SCRIPT="diff -u" INSTALL_DOTFILE="diff -u" install

reverse-install:
	@for file in $(SCRIPTS) ; do \
	    diff $(DESTDIR)/$(bindir)/$$file $$file > /dev/null && continue;\
	    echo "reverse installing $$file" ;\
	    cp $(DESTDIR)/$(bindir)/$$file $$file;\
	done
	@for file in $(DOTFILES) ; do \
	    diff $(DESTDIR)/$(dotdir)/.$$file $$file > /dev/null && continue;\
	    echo "reverse installing $$file" ;\
	    cp $(DESTDIR)/$(dotdir)/.$$file $$file;\
	done
