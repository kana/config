INSTALLATION_DIR := $(HOME)
RENAME_TARGET = $(INSTALLATION_DIR)/.vim/pack/my/start/$(subst /,-,$(1))
PLUGIN_NAMES := $(wildcard */*)


.PHONY: all install

all:

install: $(foreach t,$(PLUGIN_NAMES),$(call RENAME_TARGET,$(t)))

define generate_rule_to_install_a_target  # (build_target, install_target)
install: $(2)
$(2): $(1)
	@echo 'INSTALL $(1)'
	@rm -rf '$(2)'
	@cd '$(1)' && git checkout-index -a -f --prefix='$(2)/'
	@vim -u NONE -i NONE -n -N -e -s -c 'silent! helptags $(2)/doc | qall!'
endef
$(eval \
  $(foreach t, \
    $(PLUGIN_NAMES), \
    $(call generate_rule_to_install_a_target,$(t),$(call RENAME_TARGET,$(t)))))

# __END__
