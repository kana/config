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

syntax/,scheme.vim.snippet: tools/generate-vim-script-for-gauche
	./tools/generate-vim-script-for-gauche >"$@"

syntax/scheme.vim: syntax/scheme.vim.tmpl syntax/,scheme.vim.snippet
	sed -ne '/{{gauche-definition}}/!{p;b};r syntax/,scheme.vim.snippet' \
	  <"$<" >"$@"

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
