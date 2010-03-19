# Makefile for git

INSTALLATION_DIR := $(HOME)
RENAME_TARGET = $(patsubst dot.%,$(INSTALLATION_DIR)/.%,$(1))
TARGETS_GENERATED = dot.gitconfig
TARGETS_STATIC = $(filter-out %.in,$(filter dot.%,$(all_files_in_repos)))

define TEST_RULE
	@ruby gitconfig-compiler.rb <$< 2>&1 | sed "s|$$HOME|HOME|" >$@
endef
TEST_RULE_DEPS := gitconfig-compiler.rb

dot.gitconfig: dot.gitconfig.in gitconfig-compiler.rb
	ruby gitconfig-compiler.rb <$< >$@




include ../mduem/Makefile

# __END__
