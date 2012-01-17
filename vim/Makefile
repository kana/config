# Makefile for vim

vim_plugins := \
	altercmd \
	altr \
	arpeggio \
	bundle \
	exjumplist \
	fakeclip \
	filetype-haskell \
	flydiff \
	grex \
	metarw \
	metarw-git \
	narrow \
	operator-replace \
	operator-user \
	repeat \
	scratch \
	skeleton \
	smartchr \
	smarttill \
	smartword \
	submode \
	surround \
	textobj-datetime \
	textobj-diff \
	textobj-entire \
	textobj-fold \
	textobj-function \
	textobj-indent \
	textobj-jabraces \
	textobj-lastpat \
	textobj-line \
	textobj-syntax \
	textobj-user \
	vcsi \
	vspec \
	wwwsearch \
	xml-autons \
	xml-move \
#__

packages := $(vim_plugins) personal

%:
	for i in $(packages); do \
	  $(MAKE) -C "./$$i" '$@'; \
	done

# __END__
