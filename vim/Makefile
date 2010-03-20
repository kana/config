# Makefile for vim

vim_plugins := \
#__

packages := $(vim_plugins) personal

%:
	for i in $(packages); do \
	  $(MAKE) -C "./$$i" '$@'; \
	done

# __END__
