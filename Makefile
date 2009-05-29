# Makefile to update config.
# NOTE: GNU make is required.
ID=$$Id$$#{{{1

all: update
.PHONY: \
  _validate-package-arguments \
  _validate-package-name \
  _validate-package-type \
  _vimup \
  all \
  clean \
  clean-vim \
  list-available-packages \
  list-files-in-a-package \
  package \
  test \
  test-a-package \
  generate-missing-files-to-test \
  update \
  vimup \
  vimup-details \
  vimup-new \
  vimup-script

SHELL=/bin/sh
# For testing `update', use like DESTDIR=./test
DESTDIR=




# Group definitions  #{{{1
ALL_GROUPS=\
  $(ALL_GROUPS_common) \
  $(ALL_GROUPS_$(ENV_WORKING)) \
  $(ALL_GROUPS_$(ENV_WORKING)_$(USER))
ALL_GROUPS_common=DOTS VIM
ALL_GROUPS_winter=COLINUX_external
ALL_GROUPS_winter_root=COLINUX_internal
ALL_GROUPS_summer=CEREJA COLINUX_external DOTS_summer OPERA SAMURIZE
ALL_GROUPS_linux=DOTS_linux
ALL_GROUPS_avril=OPERA

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
GROUP_COLINUX_internal_POST_TARGETS=post-colinux-etc-fstab-inplace
define post-colinux-etc-fstab-inplace
post-colinux-etc-fstab-inplace: /etc/fstab~
/etc/fstab~: /etc/fstab
	if [ -z '$(NORMAL_USER)' ]; then \
	  echo 'NORMAL_USER is required.'; \
	  false; \
	fi
	sed -e 's/@@USER@@/$(NORMAL_USER)/g' -i~ $$<
endef

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
  dot.gitconfig \
  dot.gitignore \
  dot.guile \
  dot.screenrc \
  dot.screen/conf \
  dot.screen/keys \
  dot.screen/keys.clear \
  dot.sh_common_login \
  dot.Xdefaults \
  dot.zprofile \
  dot.zshrc
GROUP_DOTS_RULE=$(patsubst dot.%,$(HOME)/.%,$(1))
dot.gitconfig: dot.gitconfig.in
	sed -e 's!= ~/!= $(HOME)/!' <$< >$@

GROUP_DOTS_summer_FILES=\
  dot.mayu
GROUP_DOTS_summer_RULE=$(GROUP_DOTS_RULE)

GROUP_DOTS_linux_FILES=\
  dot.xmodmaprc \
  dot.xmodmaprc-dvorak
GROUP_DOTS_linux_RULE=$(GROUP_DOTS_RULE)

GROUP_OPERA_FILES=$(GROUP_OPERA_$(ENV_WORKING)_FILES)
GROUP_OPERA_summer_FILES=\
  opera/keyboard/my-keyboard-9.60.ini \
  opera/keyboard/my-keyboard-revised.ini \
  opera/keyboard/my-keyboard.ini \
  opera/menu/my-menu.ini \
  opera/search.ini \
  opera/skin/windows_skin3.zip \
  opera/styles/user.css \
  opera/toolbar/my-toolbar.ini
GROUP_OPERA_avril_FILES=\
  opera/Keyboard/my-keyboard-9.60.ini \
  opera/Keyboard/my-keyboard-revised.ini \
  opera/Keyboard/my-keyboard.ini \
  opera/Menu/my-menu.ini \
  opera/Mouse/my-mouse.ini \
  opera/search.ini \
  opera/Skin/windows_skin3.zip \
  opera/Styles/user.css \
  opera/Toolbars/my-toolbar.ini
GROUP_OPERA_RULE=$(patsubst opera/%,$(GROUP_OPERA_DIR)/%,$(1))
GROUP_OPERA_DIR=$(abspath opera/profile-link)

GROUP_SAMURIZE_FILES=\
  samurize/my-conf.ini
GROUP_SAMURIZE_RULE=$(patsubst samurize/%,$(GROUP_SAMURIZE_DIR)/%,$(1))
GROUP_SAMURIZE_DIR=$(abspath samurize/profile-link)

GROUP_VIM_FILES=\
  $(PACKAGE_vim_altkwprg_FILES) \
  $(PACKAGE_vim_arpeggio_FILES) \
  $(PACKAGE_vim_bundle_FILES) \
  $(PACKAGE_vim_fakeclip_FILES) \
  $(PACKAGE_vim_flydiff_FILES) \
  $(PACKAGE_vim_ft_gauche_FILES) \
  $(PACKAGE_vim_ft_haskell_FILES) \
  $(PACKAGE_vim_idwintab_FILES) \
  $(PACKAGE_vim_ku_FILES) \
  $(PACKAGE_vim_ku_args_FILES) \
  $(PACKAGE_vim_ku_bundle_FILES) \
  $(PACKAGE_vim_ku_metarw_FILES) \
  $(PACKAGE_vim_ku_quickfix_FILES) \
  $(PACKAGE_vim_metarw_FILES) \
  $(PACKAGE_vim_metarw_git_FILES) \
  $(PACKAGE_vim_narrow_FILES) \
  $(PACKAGE_vim_repeat_FILES) \
  $(PACKAGE_vim_scratch_FILES) \
  $(PACKAGE_vim_skeleton_FILES) \
  $(PACKAGE_vim_smartchr_FILES) \
  $(PACKAGE_vim_smartword_FILES) \
  $(PACKAGE_vim_submode_FILES) \
  $(PACKAGE_vim_surround_FILES) \
  $(PACKAGE_vim_textobj_datetime_FILES) \
  $(PACKAGE_vim_textobj_diff_FILES) \
  $(PACKAGE_vim_textobj_entire_FILES) \
  $(PACKAGE_vim_textobj_fold_FILES) \
  $(PACKAGE_vim_textobj_function_FILES) \
  $(PACKAGE_vim_textobj_indent_FILES) \
  $(PACKAGE_vim_textobj_jabraces_FILES) \
  $(PACKAGE_vim_textobj_lastpat_FILES) \
  $(PACKAGE_vim_textobj_user_FILES) \
  $(PACKAGE_vim_vcsi_FILES) \
  $(PACKAGE_vim_xml_autons_FILES) \
  $(PACKAGE_vim_xml_move_FILES) \
  $(PACKAGE_vim_misc_FILES)
GROUP_VIM_RULE=$(patsubst vim/dot.%,$(HOME)/.%,$(1))
GROUP_VIM_POST_TARGETS=post-vim-update-local-helptags
define post-vim-update-local-helptags
post-vim-update-local-helptags: $(DESTDIR)$(HOME)/.vim/doc/tags
$(DESTDIR)$(HOME)/.vim/doc/tags: \
		$(filter vim/dot.vim/doc/%.txt,$(GROUP_VIM_FILES))
	vim -n -N -u NONE -U NONE -e -c 'helptags $$(dir $$@) | quit'
endef

,gauche-modules:
	for d in `gosh -b -e ' \
	          (for-each \
		    (lambda (path) \
		      (display path) \
		      (newline)) \
		    *load-path*) \
		  ' </dev/null`; do \
	  cd $$d \
	  && find -name '*.scm' \
	     | perl -pe 's!^\./!!; s!\.scm$$!!; s!/!.!g;'; \
	done | sort --unique >$@
,gauche-symbols: gauche-generate-symbols.scm ,gauche-modules
	gosh gauche-generate-symbols.scm <,gauche-modules | sort --unique >$@
vim/dot.vim/syntax/scheme.vim: gauche-generate-syntax-vim.scm \
		,gauche-modules ,gauche-symbols \
		vim/dot.vim/syntax/scheme.vim.tmpl
	gosh gauche-generate-syntax-vim.scm \
	  ,gauche-modules ,gauche-symbols \
	  vim/dot.vim/syntax/scheme.vim.tmpl \
	  >$@




# Package definitions  #{{{1
ALL_PACKAGES=\
  all \
  cereja-all \
  opera-all \
  vim-all \
  vim-altkwprg \
  vim-arpeggio \
  vim-bundle \
  vim-fakeclip \
  vim-flydiff \
  vim-ft-gauche \
  vim-ft-haskell \
  vim-idwintab \
  vim-ku \
  vim-ku-args \
  vim-ku-buffer \
  vim-ku-bundle \
  vim-ku-file \
  vim-ku-history \
  vim-ku-metarw \
  vim-ku-quickfix \
  vim-ku-source \
  vim-metarw \
  vim-metarw-git \
  vim-misc \
  vim-narrow \
  vim-repeat \
  vim-scratch \
  vim-skeleton \
  vim-smartchr \
  vim-smartword \
  vim-submode \
  vim-surround \
  vim-textobj-datetime \
  vim-textobj-diff \
  vim-textobj-entire \
  vim-textobj-fold \
  vim-textobj-function \
  vim-textobj-indent \
  vim-textobj-jabraces \
  vim-textobj-lastpat \
  vim-textobj-user \
  vim-vcsi \
  vim-xml_autons \
  vim-xml_move

PACKAGE_all_ARCHIVE=all
PACKAGE_all_BASE=.
PACKAGE_all_FILES=./Makefile \
                  $(foreach w, common winter winter_root summer linux, \
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

PACKAGE_vim_altkwprg_ARCHIVE=vim-altkwprg-0.0.0
PACKAGE_vim_altkwprg_BASE=vim/dot.vim
PACKAGE_vim_altkwprg_FILES=\
  vim/dot.vim/autoload/altkwprg.vim \
  vim/dot.vim/doc/altkwprg.txt \
  vim/dot.vim/plugin/altkwprg.vim

PACKAGE_vim_arpeggio_ARCHIVE=vim-arpeggio-0.0.5
PACKAGE_vim_arpeggio_BASE=vim/dot.vim
PACKAGE_vim_arpeggio_FILES=\
  vim/dot.vim/after/syntax/vim/arpeggio.vim \
  vim/dot.vim/autoload/arpeggio.vim \
  vim/dot.vim/doc/arpeggio.txt \
  vim/dot.vim/plugin/arpeggio.vim

PACKAGE_vim_bundle_ARCHIVE=vim-bundle-0.0.2
PACKAGE_vim_bundle_BASE=vim/dot.vim
PACKAGE_vim_bundle_FILES=\
  vim/dot.vim/autoload/bundle.vim \
  vim/dot.vim/doc/bundle.txt \
  vim/dot.vim/plugin/bundle.vim

PACKAGE_vim_fakeclip_ARCHIVE=vim-fakeclip-0.2.3
PACKAGE_vim_fakeclip_BASE=vim/dot.vim
PACKAGE_vim_fakeclip_FILES=\
  vim/dot.vim/autoload/fakeclip.vim \
  vim/dot.vim/doc/fakeclip.txt \
  vim/dot.vim/plugin/fakeclip.vim

PACKAGE_vim_flydiff_ARCHIVE=vim-flydiff-0.0.1
PACKAGE_vim_flydiff_BASE=vim/dot.vim
PACKAGE_vim_flydiff_FILES=\
  vim/dot.vim/autoload/flydiff.vim \
  vim/dot.vim/doc/flydiff.txt \
  vim/dot.vim/plugin/flydiff.vim

PACKAGE_vim_ft_gauche_ARCHIVE=vim-ft-gauche-0.0.0
PACKAGE_vim_ft_gauche_BASE=vim/dot.vim
PACKAGE_vim_ft_gauche_FILES=\
  vim/dot.vim/syntax/scheme.vim

PACKAGE_vim_ft_haskell_ARCHIVE=vim-ft-haskell-0.0.0
PACKAGE_vim_ft_haskell_BASE=vim/dot.vim
PACKAGE_vim_ft_haskell_FILES=\
  vim/dot.vim/indent/haskell.vim \
  vim/dot.vim/syntax/haskell.vim

PACKAGE_vim_idwintab_ARCHIVE=vim-idwintab-0.0.1
PACKAGE_vim_idwintab_BASE=vim/dot.vim
PACKAGE_vim_idwintab_FILES=\
  vim/dot.vim/autoload/idwintab.vim \
  vim/dot.vim/doc/idwintab.txt

PACKAGE_vim_ku_ARCHIVE=vim-ku-0.2.4.1
PACKAGE_vim_ku_BASE=vim/dot.vim
PACKAGE_vim_ku_FILES=\
  vim/dot.vim/autoload/ku.vim \
  vim/dot.vim/doc/ku.txt \
  vim/dot.vim/plugin/ku.vim \
  vim/dot.vim/syntax/ku.vim \
  $(PACKAGE_vim_ku_buffer_FILES) \
  $(PACKAGE_vim_ku_file_FILES) \
  $(PACKAGE_vim_ku_history_FILES) \
  $(PACKAGE_vim_ku_source_FILES)

PACKAGE_vim_ku_args_ARCHIVE=vim-ku-args-0.1.1
PACKAGE_vim_ku_args_BASE=vim/dot.vim
PACKAGE_vim_ku_args_FILES=\
  vim/dot.vim/autoload/ku/args.vim \
  vim/dot.vim/doc/ku-args.txt

PACKAGE_vim_ku_buffer_ARCHIVE=vim-ku-buffer-0.1.1
PACKAGE_vim_ku_buffer_BASE=vim/dot.vim
PACKAGE_vim_ku_buffer_FILES=\
  vim/dot.vim/autoload/ku/buffer.vim \
  vim/dot.vim/doc/ku-buffer.txt

PACKAGE_vim_ku_bundle_ARCHIVE=vim-ku-bundle-0.1.1
PACKAGE_vim_ku_bundle_BASE=vim/dot.vim
PACKAGE_vim_ku_bundle_FILES=\
  vim/dot.vim/autoload/ku/bundle.vim \
  vim/dot.vim/doc/ku-bundle.txt

PACKAGE_vim_ku_file_ARCHIVE=vim-ku-file-0.1.4
PACKAGE_vim_ku_file_BASE=vim/dot.vim
PACKAGE_vim_ku_file_FILES=\
  vim/dot.vim/autoload/ku/file.vim \
  vim/dot.vim/doc/ku-file.txt

PACKAGE_vim_ku_history_ARCHIVE=vim-ku-history-0.1.1
PACKAGE_vim_ku_history_BASE=vim/dot.vim
PACKAGE_vim_ku_history_FILES=\
  vim/dot.vim/autoload/ku/history.vim \
  vim/dot.vim/doc/ku-history.txt

PACKAGE_vim_ku_metarw_ARCHIVE=vim-ku-metarw-0.1.2
PACKAGE_vim_ku_metarw_BASE=vim/dot.vim
PACKAGE_vim_ku_metarw_FILES=\
  vim/dot.vim/autoload/ku/metarw.vim \
  vim/dot.vim/doc/ku-metarw.txt

PACKAGE_vim_ku_quickfix_ARCHIVE=vim-ku-quickfix-0.1.1
PACKAGE_vim_ku_quickfix_BASE=vim/dot.vim
PACKAGE_vim_ku_quickfix_FILES=\
  vim/dot.vim/autoload/ku/quickfix.vim \
  vim/dot.vim/doc/ku-quickfix.txt

PACKAGE_vim_ku_source_ARCHIVE=vim-ku-source-0.1.2
PACKAGE_vim_ku_source_BASE=vim/dot.vim
PACKAGE_vim_ku_source_FILES=\
  vim/dot.vim/autoload/ku/source.vim \
  vim/dot.vim/doc/ku-source.txt

PACKAGE_vim_metarw_ARCHIVE=vim-metarw-0.0.4
PACKAGE_vim_metarw_BASE=vim/dot.vim
PACKAGE_vim_metarw_FILES=\
  vim/dot.vim/autoload/metarw.vim \
  vim/dot.vim/doc/metarw.txt \
  vim/dot.vim/plugin/metarw.vim \
  vim/dot.vim/syntax/metarw.vim

PACKAGE_vim_metarw_git_ARCHIVE=vim-metarw-git-0.0.3
PACKAGE_vim_metarw_git_BASE=vim/dot.vim
PACKAGE_vim_metarw_git_FILES=\
  vim/dot.vim/autoload/metarw/git.vim \
  vim/dot.vim/doc/metarw-git.txt

PACKAGE_vim_misc_ARCHIVE=vim-misc
PACKAGE_vim_misc_BASE=.
PACKAGE_vim_misc_FILES=\
  vim/dot.vim/after/ftplugin/scheme.vim \
  vim/dot.vim/autoload/ku/myproject.vim \
  vim/dot.vim/autoload/syntaxcomplete.vim \
  vim/dot.vim/autoload/xml/svg11.vim \
  vim/dot.vim/colors/black_angus.vim \
  vim/dot.vim/colors/gothic.vim \
  vim/dot.vim/colors/less.vim \
  vim/dot.vim/ftplugin/issue.vim \
  vim/dot.vim/syntax/issue.vim \
  vim/dot.vim/syntax/rest.vim \
  vim/dot.vim/xtr/skeleton/help-doc \
  vim/dot.vim/xtr/skeleton/vim-additional-ftplugin \
  vim/dot.vim/xtr/skeleton/vim-additional-indent \
  vim/dot.vim/xtr/skeleton/vim-additional-syntax \
  vim/dot.vim/xtr/skeleton/vim-autoload \
  vim/dot.vim/xtr/skeleton/vim-ftplugin \
  vim/dot.vim/xtr/skeleton/vim-indent \
  vim/dot.vim/xtr/skeleton/vim-plugin \
  vim/dot.vim/xtr/skeleton/vim-syntax \
  vim/dot.vimrc

PACKAGE_vim_narrow_ARCHIVE=vim-narrow-0.2.1
PACKAGE_vim_narrow_BASE=vim/dot.vim
PACKAGE_vim_narrow_FILES=\
  vim/dot.vim/autoload/narrow.vim \
  vim/dot.vim/doc/narrow.txt \
  vim/dot.vim/plugin/narrow.vim

PACKAGE_vim_repeat_ARCHIVE=vim-repeat-0.0.0
PACKAGE_vim_repeat_BASE=vim/dot.vim
PACKAGE_vim_repeat_FILES=\
  vim/dot.vim/autoload/repeat.vim \
  vim/dot.vim/doc/repeat.txt \
  vim/dot.vim/plugin/repeat.vim

PACKAGE_vim_scratch_ARCHIVE=vim-scratch-0.1+
PACKAGE_vim_scratch_BASE=vim/dot.vim
PACKAGE_vim_scratch_FILES=\
  vim/dot.vim/autoload/scratch.vim \
  vim/dot.vim/doc/scratch.txt \
  vim/dot.vim/plugin/scratch.vim

PACKAGE_vim_skeleton_ARCHIVE=vim-skeleton-0.0.2
PACKAGE_vim_skeleton_BASE=vim/dot.vim
PACKAGE_vim_skeleton_FILES=\
  vim/dot.vim/doc/skeleton.txt \
  vim/dot.vim/plugin/skeleton.vim

PACKAGE_vim_smartchr_ARCHIVE=vim-smartchr-0.0.1
PACKAGE_vim_smartchr_BASE=vim/dot.vim
PACKAGE_vim_smartchr_FILES=\
  vim/dot.vim/autoload/smartchr.vim \
  vim/dot.vim/doc/smartchr.txt

PACKAGE_vim_smartword_ARCHIVE=vim-smartword-0.0.2
PACKAGE_vim_smartword_BASE=vim/dot.vim
PACKAGE_vim_smartword_FILES=\
  vim/dot.vim/autoload/smartword.vim \
  vim/dot.vim/doc/smartword.txt \
  vim/dot.vim/plugin/smartword.vim

PACKAGE_vim_submode_ARCHIVE=vim-submode-0.0.0
PACKAGE_vim_submode_BASE=vim/dot.vim
PACKAGE_vim_submode_FILES=\
  vim/dot.vim/autoload/submode.vim \
  vim/dot.vim/doc/submode.txt

PACKAGE_vim_surround_ARCHIVE=vim-surround-1.34.7
PACKAGE_vim_surround_BASE=vim/dot.vim
PACKAGE_vim_surround_FILES=\
  vim/dot.vim/doc/surround.txt \
  vim/dot.vim/plugin/surround.vim \
  vim/dot.vim/plugin/surround_config.vim

PACKAGE_vim_textobj_datetime_ARCHIVE=vim-textobj-datetime-0.3.1
PACKAGE_vim_textobj_datetime_BASE=vim/dot.vim
PACKAGE_vim_textobj_datetime_FILES=\
  vim/dot.vim/doc/textobj-datetime.txt \
  vim/dot.vim/plugin/textobj/datetime.vim

PACKAGE_vim_textobj_diff_ARCHIVE=vim-textobj-diff-0.0.0
PACKAGE_vim_textobj_diff_BASE=vim/dot.vim
PACKAGE_vim_textobj_diff_FILES=\
  vim/dot.vim/doc/textobj-diff.txt \
  vim/dot.vim/plugin/textobj/diff.vim

PACKAGE_vim_textobj_entire_ARCHIVE=vim-textobj-entire-0.0.0
PACKAGE_vim_textobj_entire_BASE=vim/dot.vim
PACKAGE_vim_textobj_entire_FILES=\
  vim/dot.vim/doc/textobj-entire.txt \
  vim/dot.vim/plugin/textobj/entire.vim

PACKAGE_vim_textobj_fold_ARCHIVE=vim-textobj-fold-0.1.2
PACKAGE_vim_textobj_fold_BASE=vim/dot.vim
PACKAGE_vim_textobj_fold_FILES=\
  vim/dot.vim/doc/textobj-fold.txt \
  vim/dot.vim/plugin/textobj/fold.vim

PACKAGE_vim_textobj_function_ARCHIVE=vim-textobj-function-0.1.0
PACKAGE_vim_textobj_function_BASE=vim/dot.vim
PACKAGE_vim_textobj_function_FILES=\
  vim/dot.vim/after/ftplugin/c/textobj-function.vim \
  vim/dot.vim/after/ftplugin/vim/textobj-function.vim \
  vim/dot.vim/doc/textobj-function-c.txt \
  vim/dot.vim/doc/textobj-function-vim.txt \
  vim/dot.vim/doc/textobj-function.txt \
  vim/dot.vim/plugin/textobj/function.vim

PACKAGE_vim_textobj_indent_ARCHIVE=vim-textobj-indent-0.0.2
PACKAGE_vim_textobj_indent_BASE=vim/dot.vim
PACKAGE_vim_textobj_indent_FILES=\
  vim/dot.vim/doc/textobj-indent.txt \
  vim/dot.vim/plugin/textobj/indent.vim

PACKAGE_vim_textobj_jabraces_ARCHIVE=vim-textobj-jabraces-0.1.1
PACKAGE_vim_textobj_jabraces_BASE=vim/dot.vim
PACKAGE_vim_textobj_jabraces_FILES=\
  vim/dot.vim/doc/textobj-jabraces.txt \
  vim/dot.vim/plugin/textobj/jabraces.vim

PACKAGE_vim_textobj_lastpat_ARCHIVE=vim-textobj-lastpat-0.0.0
PACKAGE_vim_textobj_lastpat_BASE=vim/dot.vim
PACKAGE_vim_textobj_lastpat_FILES=\
  vim/dot.vim/doc/textobj-lastpat.txt \
  vim/dot.vim/plugin/textobj/lastpat.vim

PACKAGE_vim_textobj_user_ARCHIVE=vim-textobj-user-0.3.7
PACKAGE_vim_textobj_user_BASE=vim/dot.vim
PACKAGE_vim_textobj_user_FILES=\
  vim/dot.vim/autoload/textobj/user.vim \
  vim/dot.vim/doc/textobj-user.txt

PACKAGE_vim_vcsi_ARCHIVE=vim-vcsi-0.1.0
PACKAGE_vim_vcsi_BASE=vim/dot.vim
PACKAGE_vim_vcsi_FILES=\
  vim/dot.vim/after/ftplugin/vcsi.vim \
  vim/dot.vim/after/syntax/vcsi.vim \
  vim/dot.vim/autoload/vcsi.vim \
  vim/dot.vim/doc/vcsi.txt \
  vim/dot.vim/plugin/vcsi.vim

PACKAGE_vim_xml_autons_ARCHIVE=vim-xml_autons-0.0.1
PACKAGE_vim_xml_autons_BASE=vim/dot.vim
PACKAGE_vim_xml_autons_FILES=\
  vim/dot.vim/after/ftplugin/xml_autons.vim \
  vim/dot.vim/doc/xml_autons.txt

PACKAGE_vim_xml_move_ARCHIVE=vim-xml_move-0.0.2
PACKAGE_vim_xml_move_BASE=vim/dot.vim
PACKAGE_vim_xml_move_FILES=\
  vim/dot.vim/after/ftplugin/xml_move.vim \
  vim/dot.vim/doc/xml_move.txt




# package  #{{{1

PACKAGE_NAME=# Set from command line
_PACKAGE_NAME=$(subst -,_,$(PACKAGE_NAME))
PACKAGE_TYPE=tar

ALL_PACKAGE_TYPES=tar zip
PACKAGE_COMMAND_tar=tar jcvf
PACKAGE_SUFFIX_tar=.tar.bz2
PACKAGE_COMMAND_zip=zip
PACKAGE_SUFFIX_zip=.zip

package: _validate-package-arguments test-a-package
	ln -s $(PACKAGE_$(_PACKAGE_NAME)_BASE) \
	      $(PACKAGE_$(_PACKAGE_NAME)_ARCHIVE)
	$(PACKAGE_COMMAND_$(PACKAGE_TYPE)) \
	  $(PACKAGE_$(_PACKAGE_NAME)_ARCHIVE)$(PACKAGE_SUFFIX_$(PACKAGE_TYPE))\
	  $(foreach file, \
	            $(PACKAGE_$(_PACKAGE_NAME)_FILES), \
	            $(patsubst $(PACKAGE_$(_PACKAGE_NAME)_BASE)/%, \
	                       $(PACKAGE_$(_PACKAGE_NAME)_ARCHIVE)/%, \
	                       $(file)))
	rm $(PACKAGE_$(_PACKAGE_NAME)_ARCHIVE)
_validate-package-arguments: _validate-package-name _validate-package-type
_validate-package-name:
	@if [ -z '$(filter $(PACKAGE_NAME),$(ALL_PACKAGES))' ]; then \
	  echo 'Error: Invalid PACKAGE_NAME "$(PACKAGE_NAME)".'; \
	  false; \
	fi
_validate-package-type:
	@if [ -z '$(filter $(PACKAGE_TYPE),$(ALL_PACKAGE_TYPES))' ]; then \
	  echo 'Error: Invalid PACKAGE_TYPE "$(PACKAGE_TYPE)".'; \
	  false; \
	fi


# for vim-bundle

list-available-packages:
	@echo $(ALL_PACKAGES)

list-files-in-a-package:
	@if [ -z '$(filter $(PACKAGE_NAME),$(ALL_PACKAGES))' ]; then \
	  echo 'Error: Invalid PACKAGE_NAME "$(PACKAGE_NAME)".'; \
	  false; \
	fi
	@echo $(PACKAGE_$(_PACKAGE_NAME)_FILES)




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
$(foreach group, \
  $(ALL_GROUPS), \
  $(foreach post-target, \
    $(GROUP_$(group)_POST_TARGETS), \
    $(eval $($(post-target)))))




# vimup  #{{{1
# -- to automate to upload Vim scripts.

#VIMUP_TASKS=
_vimup:
	./vimup-info-generator \
	  <$(filter vim/dot.vim/doc/$(patsubst vim-%,%,$(PACKAGE_NAME)).txt, \
	            $(PACKAGE_$(_PACKAGE_NAME)_FILES)) \
	  >$(PACKAGE_NAME).vimup
	for i in $(VIMUP_TASKS); do \
	  vimup $$i $(PACKAGE_NAME); \
	done
	rm $(PACKAGE_NAME).vimup

vimup: package
	make VIMUP_TASKS="update-script update-details" _vimup
vimup-details:
	make VIMUP_TASKS=update-details _vimup
vimup-new: package
	make VIMUP_TASKS=new-script _vimup
vimup-script: package
	make VIMUP_TASKS=update-script _vimup




# clean  #{{{1

clean:
	rm -rf `find -name '*~' \
	         -or -name ',*' \
	         -or -name '*.ok' \
	         -or -name '*.output'`

clean-vim:
	rm -rf `find $(HOME)/.vim \
	        -mindepth 1 -maxdepth 1 \
	        -not -name 'info' -not -name 'xtr'`




# test  #{{{1
# Core  #{{{2
test:
	for i in $(ALL_PACKAGES); do \
	  $(MAKE) PACKAGE_NAME=$$i test-a-package || exit 1; \
	done

test-a-package: _validate-package-name  # (PACKAGE_NAME)
	@if [ -d test/$(PACKAGE_NAME) ]; then \
	  $(MAKE) test/$(PACKAGE_NAME).ok; \
	else \
	  echo 'test-a-package: Nothing to do for $(PACKAGE_NAME)'; \
	fi

test/%.ok: test/%.expected test/%.output
	@echo -n 'TEST: $(<:.expected=) ... '
	@diff -u $^ >,,test-$$$$; \
	 result=$$?; \
	 if [ "$$result" = '0' ]; then \
	   echo 'ok'; \
	 else \
	   echo 'FAILED'; \
	   cat ,,test-$$$$; \
	   echo 'END'; \
	   false; \
	 fi; \
	 rm ,,test-$$$$; \
	 exit $$result
	@touch $@

generate-missing-files-to-test: _validate-package-name  # (PACKAGE_NAME)
	for i in $(TESTS_$(_PACKAGE_NAME)); do \
	  if ! [ -f test/$(PACKAGE_NAME)/$$i.input ]; then \
	    echo "# Add files for $$i"; \
	    mkdir -p test/$(PACKAGE_NAME); \
	    touch test/$(PACKAGE_NAME)/$$i.input \
	          test/$(PACKAGE_NAME)/$$i.expected; \
	    git add test/$(PACKAGE_NAME)/$$i.input \
	            test/$(PACKAGE_NAME)/$$i.expected; \
	  fi; \
	done


# vim-ku  #{{{2
TESTS_vim_ku = 0001 0002 0003

test/vim-ku/%.output: \
		test/vim-ku/%.input \
		test/tester-vim \
		test/libtest.vim \
		vim/dot.vim/autoload/ku.vim \
		vim/dot.vim/plugin/ku.vim
	@./test/tester-vim $< 'plugin/ku.vim' &>$@


# vim-ku-file  #{{{2
TESTS_vim_ku_file = 0001

test/vim-ku-file/%.output: \
		test/vim-ku-file/%.input \
		test/libtest.vim \
		test/tester-vim \
		vim/dot.vim/autoload/ku.vim \
		vim/dot.vim/autoload/ku/file.vim \
		vim/dot.vim/plugin/ku.vim
	@./test/tester-vim $< 'plugin/ku.vim autoload/ku.vim' &>$@


# Misc.  #{{{2

define GENERATE_DEPENDENCY_RULES_TO_TEST_1
test/$(1).ok: $(foreach n,$(TESTS_$(subst -,_,$(1))),test/$(1)/$(n).ok)
	touch test/$(1).ok
endef

define GENERATE_DEPENDENCY_RULES_TO_TEST_2
test/$(1)/$(2).ok: test/$(1)/$(2).expected test/$(1)/$(2).output
test/$(1)/$(2).output: test/$(1)/$(2).input
endef

$(foreach package, $(ALL_PACKAGES), \
  $(eval $(call GENERATE_DEPENDENCY_RULES_TO_TEST_1,$(package))) \
  $(foreach case, $(TESTS_$(subst -,_,$(package))), \
    $(eval $(call GENERATE_DEPENDENCY_RULES_TO_TEST_2,$(package),$(case)))))




# __END__  #{{{1
# vim: foldmethod=marker
