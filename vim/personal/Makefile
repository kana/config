# Makefile for vim/personal
# FIXME: "test" doesn't work.
# FIXME: "release" doesn't work.

REPOS_TYPE := vim-script
INSTALLATION_DIR := $(HOME)
RENAME_TARGET = $(INSTALLATION_DIR)/.vim$(if $(filter dot.%,$(1)),rc,/$(1))
TARGETS_GENERATED := syntax/scheme.vim
TARGETS_STATIC = $(filter-out \
		     Makefile \
		     gauche-%.scm \
		     syntax/%.vim.tmpl \
		     test/%, \
		   $(all_files_in_repos))



all:

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

syntax/scheme.vim: \
		syntax/scheme.vim.tmpl \
		gauche-generate-syntax-vim.scm \
		,gauche-modules \
		,gauche-symbols
	gosh gauche-generate-syntax-vim.scm \
	  ,gauche-modules ,gauche-symbols \
	  $< \
	  >$@

# NB: Every make for each vim/$plugin tries to update doc/tags, but doc/tags
# is updated by make for vim/$first_plugin, so make for vim/$other_plugins
# doesn't update doc/tags.  Because recursively called make doesn't know
# dependencies about other make instances.  Therefore, doc/tags is not updated
# correctly if documents of vim/$plugin_a and vim/$plugin_b have been updated.
#
# To avoid the problem,
# (1) Make for vim/personal is called after vim/$all_other_plugins.
# (2) In make for vim/personal, rule to update doc/tags is always executed.
#
# FIXME: Execute the rule to update doc/tags if it is really necessary.
.PHONY: force
$(call RENAME_TARGET,doc/tags): force




include ../../mduem/Makefile

# __END__
