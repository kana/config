# Makefile to update config.
# NOTE: GNU make is required.
ID=$$Id$$#{{{1

all: update
.PHONY: all clean update update-dot-files update-opera

SHELL=/bin/sh
# For testing `update', use like DESTDIR=./test
DESTDIR=
UPDATE_DIR=mkdir -p
UPDATE_FILE=cp




# update  #{{{1
update: update-dot-files update-opera


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
	$(UPDATE_DIR) $@
$(DESTDIR)$(HOME)/.%: dot.%
	$(UPDATE_FILE) $< $@


# update-opera  #{{{2

OPERA_USER_PROFILE=/c/Documents\ and\ Settings/kana/Application\ Data/Opera/Opera9/profile
OPERA_FILES=\
  keyboard/my-keyboard.ini \
  keyboard/standard_keyboard-stripped.ini \
  menu/my-menu.ini \
  search.ini \
  styles/user.css \
  toolbar/my-toolbar.ini

update-opera: \
  $(addprefix $(DESTDIR)$(OPERA_USER_PROFILE)/,$(OPERA_FILES))

define opera_file_template
$(DESTDIR)$(OPERA_USER_PROFILE)/$(1): \
  opera/$(1) \
  $(DESTDIR)$(OPERA_USER_PROFILE)/$(dir $(1))
	$(UPDATE_FILE) $$< '$$@'
endef
$(foreach i, \
          $(OPERA_FILES), \
          $(eval $(call opera_file_template,$(i))))

define opera_dir_template
$(DESTDIR)$(OPERA_USER_PROFILE)/$(1):
	$(UPDATE_DIR) '$$@'
endef
$(foreach i, \
          $(sort $(dir $(OPERA_FILES))), \
          $(eval $(call opera_dir_template,$(i))))




# clean  #{{{1
clean:
	rm -rf `find -name '*~' -or -name ',*'`




# __END__
# vim: foldmethod=marker
