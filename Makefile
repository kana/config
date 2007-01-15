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

RemoveDotPart=$(patsubst dot.%,.%,$(1))
RemoveCurrentDirectory=$(filter-out ./,$(1))
RemoveDuplicates=$(sort $(1))

define TemplateUpdateFile  # (src, src-base-dir, dest-base-dir)
$(DESTDIR)$(3)/$(call RemoveDotPart,$(1)): \
  $(2)/$(1) \
  $(DESTDIR)$(3)/$(call RemoveCurrentDirectory,$(dir $(1)))
	$(UPDATE_FILE) '$$<' '$$@'
endef

define TemplateUpdateDir  # ((dir src), dest-base-dir)
$(DESTDIR)$(2)/$(call RemoveDotPart,$(call RemoveCurrentDirectory,$(1))):
	$(UPDATE_DIR) '$$@'
endef


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

$(foreach src, \
  $(DOT_FILES), \
  $(eval $(call TemplateUpdateFile,$(src),.,$(HOME))))

$(foreach \
  src_dir, \
  $(call RemoveDuplicates,$(dir $(DOT_FILES))), \
  $(eval $(call TemplateUpdateDir,$(src_dir),$(HOME))))


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

$(foreach src, \
  $(OPERA_FILES), \
  $(eval $(call TemplateUpdateFile,$(src),opera,$(OPERA_USER_PROFILE))))

$(foreach src_dir, \
  $(call RemoveDuplicates,$(dir $(OPERA_FILES))), \
  $(eval $(call TemplateUpdateDir,$(src_dir),$(OPERA_USER_PROFILE))))




# clean  #{{{1
clean:
	rm -rf `find -name '*~' -or -name ',*'`




# __END__
# vim: foldmethod=marker
