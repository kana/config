INSTALLATION_DIR := $(HOME)

.PHONY: all install update

all:

install: Flavorfile.lock

update:
	bundle exec vim-flavor update

Flavorfile.lock: Flavorfile
	bundle exec vim-flavor install

# __END__
