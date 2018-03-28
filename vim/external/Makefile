INSTALLATION_DIR := $(HOME)

.PHONY: all install

all:

install: Flavorfile.lock

Flavorfile.lock: Flavorfile
	bundle exec vim-flavor install

# __END__
