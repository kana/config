# Makefile for vim

INSTALLATION_DIR := $(HOME)
VIMFILES_DIR = $(INSTALLATION_DIR)/.vim

%:
	$(MAKE) -C './personal' '$@'
	vim-flavor install --vimfiles-path='$(VIMFILES_DIR)'

# __END__
