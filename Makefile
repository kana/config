# Driver Makefile
# Requirement: GNU make

softwares_common := bin dotfiles git sh vim

softwares := \
	$(softwares_common)




all: build

%:
	for i in $(softwares); do \
	  $(MAKE) -C "./$$i" '$@'; \
	done

# __END__
