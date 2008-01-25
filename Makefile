# Makefile to update config.
# NOTE: GNU make is required.
ID=$$Id$$#{{{1

all: update
.PHONY: all clean package _package update

SHELL=/bin/sh
# For testing `update', use like DESTDIR=./test
DESTDIR=




# Group definitions  #{{{1
ALL_GROUPS=\
  $(ALL_GROUPS_common) \
  $(ALL_GROUPS_$(ENV_WORKING)) \
  $(ALL_GROUPS_$(ENV_WORKING)_$(USER))
ALL_GROUPS_common=DOTS VIM
ALL_GROUPS_colinux=COLINUX_external
ALL_GROUPS_colinux_root=COLINUX_internal
ALL_GROUPS_cygwin=CEREJA COLINUX_external DOTS_cygwin OPERA SAMURIZE
ALL_GROUPS_linux=DOTS_linux

GROUP_CEREJA_FILES=\
  cereja/config.lua \
  cereja/login.lua \
  cereja/logout.lua
GROUP_CEREJA_RULE=$(patsubst %,$(HOME)/.%,$(1))

GROUP_COLINUX_internal_FILES=\
  colinux/etc/fstab \
  colinux/etc/hostname \
  colinux/etc/hosts \
  colinux/etc/hosts.allow \
  colinux/etc/hosts.deny \
  colinux/etc/network/interfaces \
  colinux/etc/resolv.conf
GROUP_COLINUX_internal_RULE=$(patsubst colinux/%,/%,$(1))
GROUP_COLINUX_internal_POST_TARGETS=colinux-etc-fstab-inplace
colinux-etc-fstab-inplace: /etc/fstab~
/etc/fstab~: /etc/fstab
	if [ -z '$(NORMAL_USER)' ]; then \
	  echo 'NORMAL_USER is required.'; \
	  false; \
	fi
	sed -e 's/@@USER@@/$(NORMAL_USER)/g' -i~ $<

GROUP_COLINUX_external_FILES=\
  colinux/my-colinux.bat \
  colinux/my.conf
GROUP_COLINUX_external_RULE=\
  $(patsubst colinux/%,/c/cygwin/usr/win/bin/coLinux/%,$(1))

GROUP_DOTS_FILES=\
  dot.bash_profile \
  dot.bashrc \
  dot.bash.d/bash_completion \
  dot.bash.d/cdhist.sh \
  dot.bash.d/svk-completion.pl \
  dot.inputrc \
  dot.guile \
  dot.screenrc \
  dot.Xdefaults
GROUP_DOTS_RULE=$(patsubst dot.%,$(HOME)/.%,$(1))

GROUP_DOTS_cygwin_FILES=\
  dot.mayu
GROUP_DOTS_cygwin_RULE=$(GROUP_DOTS_RULE)

GROUP_DOTS_linux_FILES=\
  dot.xmodmaprc \
  dot.xmodmaprc-dvorak
GROUP_DOTS_linux_RULE=$(GROUP_DOTS_RULE)

GROUP_OPERA_FILES=\
  opera/keyboard/my-keyboard.ini \
  opera/menu/my-menu.ini \
  opera/search.ini \
  opera/skin/windows_skin3.zip \
  opera/styles/user.css \
  opera/toolbar/my-toolbar.ini
GROUP_OPERA_RULE=$(patsubst opera/%,$(GROUP_OPERA_DIR)/%,$(1))
GROUP_OPERA_DIR=$(abspath opera/profile-link)

GROUP_SAMURIZE_FILES=\
  samurize/my-conf.ini
GROUP_SAMURIZE_RULE=$(patsubst samurize/%,$(GROUP_SAMURIZE_DIR)/%,$(1))
GROUP_SAMURIZE_DIR=$(abspath samurize/profile-link)

GROUP_VIM_FILES=\
  $(GROUP_VIM_DOC_FILES) \
  vim/dot.vim/after/ftplugin/xml_autons.vim \
  vim/dot.vim/autoload/narrow.vim \
  vim/dot.vim/autoload/scratch.vim \
  vim/dot.vim/autoload/textobj/user.vim \
  vim/dot.vim/autoload/vcsi.vim \
  vim/dot.vim/autoload/xml/svg11.vim \
  vim/dot.vim/colors/black_angus.vim \
  vim/dot.vim/colors/gothic.vim \
  vim/dot.vim/colors/less.vim \
  vim/dot.vim/ftplugin/c_tofunc.vim \
  vim/dot.vim/ftplugin/issue.vim \
  vim/dot.vim/ftplugin/vim_tofunc.vim \
  vim/dot.vim/ftplugin/xml_move.vim \
  vim/dot.vim/plugin/cygclip.vim \
  vim/dot.vim/plugin/narrow.vim \
  vim/dot.vim/plugin/scratch.vim \
  vim/dot.vim/plugin/surround.vim \
  vim/dot.vim/plugin/surround_config.vim \
  vim/dot.vim/plugin/textobj/datetime.vim \
  vim/dot.vim/plugin/tofunc.vim \
  vim/dot.vim/plugin/vcsi.vim \
  vim/dot.vim/plugin/zapit.vim \
  vim/dot.vim/syntax/issue.vim \
  vim/dot.vim/syntax/rest.vim \
  vim/dot.vimrc
GROUP_VIM_RULE=$(patsubst vim/dot.%,$(HOME)/.%,$(1))
GROUP_VIM_DOC_FILES=\
  vim/dot.vim/doc/cygclip.txt \
  vim/dot.vim/doc/narrow.txt \
  vim/dot.vim/doc/scratch.txt \
  vim/dot.vim/doc/surround.txt \
  vim/dot.vim/doc/textobj-datetime.txt \
  vim/dot.vim/doc/textobj-user.txt \
  vim/dot.vim/doc/tofunc.txt \
  vim/dot.vim/doc/vcsi.txt \
  vim/dot.vim/doc/xml_autons.txt \
  vim/dot.vim/doc/xml_move.txt \
  vim/dot.vim/doc/zapit.txt
GROUP_VIM_POST_TARGETS=vim-update-local-helptags
vim-update-local-helptags: $(DESTDIR)$(HOME)/.vim/doc/tags
$(DESTDIR)$(HOME)/.vim/doc/tags: $(GROUP_VIM_DOC_FILES)
	vim -n -N -u NONE -U NONE -e -c 'helptags $(dir $@) | q'




# Package definitions  #{{{1
ALL_PACKAGES=\
  all \
  cereja-all \
  opera-all \
  vim-all \
  vim-cygclip \
  vim-narrow \
  vim-scratch \
  vim-textobj-datetime \
  vim-textobj-user \
  vim-tofunc \
  vim-vcsi \
  vim-xml_autons \
  vim-xml_move \
  vim-zapit

PACKAGE_all_ARCHIVE=all
PACKAGE_all_BASE=.
PACKAGE_all_FILES=./Makefile \
                  $(foreach w, common colinux colinux_root cygwin linux, \
                    $(foreach g, $(sort $(ALL_GROUPS_$(w))), \
                      $(foreach f, $(GROUP_$(g)_FILES), \
                        ./$(f))))

PACKAGE_cereja_all_ARCHIVE=cereja-all
PACKAGE_cereja_all_BASE=cereja
PACKAGE_cereja_all_FILES=$(GROUP_CEREJA_FILES)

PACKAGE_opera_all_ARCHIVE=opera-all
PACKAGE_opera_all_BASE=opera
PACKAGE_opera_all_FILES=$(GROUP_OPERA_FILES)

PACKAGE_vim_all_ARCHIVE=vim-all
PACKAGE_vim_all_BASE=vim
PACKAGE_vim_all_FILES=$(GROUP_VIM_FILES)

PACKAGE_vim_cygclip_ARCHIVE=vim-cygclip-0.1
PACKAGE_vim_cygclip_BASE=vim/dot.vim
PACKAGE_vim_cygclip_FILES=\
  vim/dot.vim/doc/cygclip.txt \
  vim/dot.vim/plugin/cygclip.vim

PACKAGE_vim_narrow_ARCHIVE=vim-narrow-0.2
PACKAGE_vim_narrow_BASE=vim/dot.vim
PACKAGE_vim_narrow_FILES=\
  vim/dot.vim/autoload/narrow.vim \
  vim/dot.vim/doc/narrow.txt \
  vim/dot.vim/plugin/narrow.vim

PACKAGE_vim_scratch_ARCHIVE=vim-scratch-0.1+
PACKAGE_vim_scratch_BASE=vim/dot.vim
PACKAGE_vim_scratch_FILES=\
  vim/dot.vim/autoload/scratch.vim \
  vim/dot.vim/doc/scratch.txt \
  vim/dot.vim/plugin/scratch.vim

PACKAGE_vim_textobj_datetime_ARCHIVE=vim-textobj-datetime-0.2
PACKAGE_vim_textobj_datetime_BASE=vim/dot.vim
PACKAGE_vim_textobj_datetime_FILES=\
  vim/dot.vim/doc/textobj-datetime.txt \
  vim/dot.vim/plugin/textobj/datetime.vim

PACKAGE_vim_textobj_user_ARCHIVE=vim-textobj-user-0.2
PACKAGE_vim_textobj_user_BASE=vim/dot.vim
PACKAGE_vim_textobj_user_FILES=\
  vim/dot.vim/autoload/textobj/user.vim \
  vim/dot.vim/doc/textobj-user.txt

PACKAGE_vim_tofunc_ARCHIVE=vim-tofunc-0.0
PACKAGE_vim_tofunc_BASE=vim/dot.vim
PACKAGE_vim_tofunc_FILES=\
  vim/dot.vim/doc/tofunc.txt \
  vim/dot.vim/ftplugin/c_tofunc.vim \
  vim/dot.vim/ftplugin/vim_tofunc.vim \
  vim/dot.vim/plugin/tofunc.vim

PACKAGE_vim_vcsi_ARCHIVE=vim-vcsi-0.0.2
PACKAGE_vim_vcsi_BASE=vim/dot.vim
PACKAGE_vim_vcsi_FILES=\
  vim/dot.vim/autoload/vcsi.vim \
  vim/dot.vim/doc/vcsi.txt \
  vim/dot.vim/plugin/vcsi.vim

PACKAGE_vim_xml_autons_ARCHIVE=vim-xml_autons-0.0.1
PACKAGE_vim_xml_autons_BASE=vim/dot.vim
PACKAGE_vim_xml_autons_FILES=\
  vim/dot.vim/after/ftplugin/xml_autons.vim \
  vim/dot.vim/doc/xml_autons.txt

PACKAGE_vim_xml_move_ARCHIVE=vim-xml_move-0.0.1
PACKAGE_vim_xml_move_BASE=vim/dot.vim
PACKAGE_vim_xml_move_FILES=\
  vim/dot.vim/doc/xml_move.txt \
  vim/dot.vim/ftplugin/xml_move.vim

PACKAGE_vim_zapit_ARCHIVE=vim-zapit-0.0
PACKAGE_vim_zapit_BASE=vim/dot.vim
PACKAGE_vim_zapit_FILES=\
  vim/dot.vim/doc/zapit.txt \
  vim/dot.vim/plugin/zapit.vim




# package  #{{{1

PACKAGE_NAME=# Set from command line
PACKAGE_TYPE=tar

ALL_PACKAGE_TYPES=tar zip
PACKAGE_COMMAND_tar=tar jcvf
PACKAGE_SUFFIX_tar=.tar.bz2
PACKAGE_COMMAND_zip=zip
PACKAGE_SUFFIX_zip=.zip

package:
	if [ -z '$(filter $(PACKAGE_NAME),$(ALL_PACKAGES))' ]; then \
	  echo 'Error: Invalid PACKAGE_NAME "$(PACKAGE_NAME)".'; \
	  false; \
	fi
	if [ -z '$(filter $(PACKAGE_TYPE),$(ALL_PACKAGE_TYPES))' ]; then \
	  echo 'Error: Invalid PACKAGE_TYPE "$(PACKAGE_TYPE)".'; \
	  false; \
	fi
	$(MAKE) 'package=$(subst -,_,$(PACKAGE_NAME))' _package
_package:
	ln -s $(PACKAGE_$(package)_BASE) $(PACKAGE_$(package)_ARCHIVE)
	$(PACKAGE_COMMAND_$(PACKAGE_TYPE)) \
	  $(PACKAGE_$(package)_ARCHIVE)$(PACKAGE_SUFFIX_$(PACKAGE_TYPE)) \
	  $(foreach file, \
	            $(PACKAGE_$(package)_FILES), \
	            $(patsubst $(PACKAGE_$(package)_BASE)/%, \
	                       $(PACKAGE_$(package)_ARCHIVE)/%, \
	                       $(file)))
	rm $(PACKAGE_$(package)_ARCHIVE)




# update  #{{{1
# Rules for `update' are generated by eval.

UPDATE_DIR=mkdir -p
UPDATE_FILE=cp

RemoveCurrentDirectory=$(filter-out ./,$(1))
RemoveDuplicates=$(sort $(1))
CallRule=$(call RemoveCurrentDirectory,$(call GROUP_$(1)_RULE,$(2)))

define GenerateRulesToUpdateFile  # (src, dest)
update: $(DESTDIR)$(2)
$(DESTDIR)$(2): $(1)
	$(UPDATE_FILE) '$$<' '$$@'

endef

define GenerateRulesToUpdateDirectory  # (dest)
update: $(DESTDIR)$(1)
$(DESTDIR)$(1):
	$(UPDATE_DIR) '$$@'

endef

define GenerateRulesFromGroups  # (groups = (group_name*))
$(foreach directory, \
  $(call RemoveDuplicates, \
    $(foreach group, \
      $(1), \
      $(dir $(call CallRule,$(group),$(GROUP_$(group)_FILES))))), \
  $(call GenerateRulesToUpdateDirectory,$(directory)))
$(foreach group, \
  $(1), \
  $(foreach file, \
    $(GROUP_$(group)_FILES), \
    $(call GenerateRulesToUpdateFile,$(file),$(call CallRule,$(group),$(file)))))
update .PHONY: $(foreach group,$(1),$(GROUP_$(group)_POST_TARGETS))
endef

$(eval $(call GenerateRulesFromGroups,$(ALL_GROUPS)))




# clean  #{{{1

clean:
	rm -rf `find -name '*~' -or -name ',*'`




# __END__
# vim: foldmethod=marker
