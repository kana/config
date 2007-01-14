# Makefile to update config.
# NOTE: GNU make is required.
ID=$$Id$$#{{{1

all: update
.PHONY: all clean update update-dot-files

SHELL=/bin/sh
# For testing `update', use like DESTDIR=./test
DESTDIR=




# update  #{{{1
update: update-dot-files


# update-dot-files  #{{{2

DOT_FILES=\
  dot.bash_profile \
  dot.bashrc \
  dot.inputrc \
  dot.mayu \
  dot.screenrc \
  dot.Xdefaults

update-dot-files: \
  $(DESTDIR)$(HOME)/ \
  $(patsubst dot.%,$(DESTDIR)$(HOME)/.%,$(DOT_FILES))

$(DESTDIR)$(HOME)/:
	mkdir -p $@
$(DESTDIR)$(HOME)/.%: dot.%
	cp -v $< $@




# clean  #{{{1
clean:
	rm -f *~ ,*




# __END__
# vim: foldmethod=marker
