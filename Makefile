# Driver Makefile
# Requirement: GNU make

softwares_common := git opera sh

softwares := \
	$(softwares_common) \
	$(softwares_$(ENV_WORKING)) \
	$(softwares_$(ENV_WORKING)_$(USER))




all: build

%:
	for i in $(softwares); do \
	  $(MAKE) -C "./$$i" '$@'; \
	done

# __END__
