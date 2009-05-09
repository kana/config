# Makefile to generate documents for GitHub Pages.

SHELL=/bin/bash
.PHONY: \
	all \
	validate-status \
	vim-all \
	vim-commit \
	vim-generate

all: vim-all
	git push github gh-pages

validate-status:
	@# FIXME: This checking is not perfect.  For example, "git rebase -i".
	@test "$$(git branch | grep '*' | sed 's/[ *]//g')" = 'gh-pages'




CMD_VIM_DOC_FILES=git ls-files HEAD 'data/vim/dot.vim/doc/*.txt'
CMD_VIM_HTML_FILES=\
	{ $(CMD_VIM_DOC_FILES) \
	| sed 's=.*/=vim/=;s=\.txt$$=.html=' \
	; echo vim/index.html \
	; } \
	| sort
CMD_VIM_DELETED_FILES=diff <(ls vim/*.html) <($(CMD_VIM_HTML_FILES)) \
	              | sed -ne '/^</{;s/< //;p;}'
vim-all: vim-commit

vim-commit: vim-generate
	git add vim/index.html $$($(CMD_VIM_HTML_FILES))
	for i in $$($(CMD_VIM_DELETED_FILES)); do \
	  git rm "$$i"; \
	done
	git commit -m "Vim documents: Reflect changes to master:$$(git rev-parse master)"

vim-generate: vim-generate-each-page vim/index.html

vim-generate-each-page:
	$(MAKE) $$($(CMD_VIM_HTML_FILES))

vim/,index.txt: vim/index.txt $(shell $(CMD_VIM_DOC_FILES))
	./generate-vimhelp-index $^ >$@

vim/index.html: vim/,index.txt validate-status
	./convert-vimhelp-to-html $< >$@
vim/%.html: data/vim/dot.vim/doc/%.txt validate-status
	./convert-vimhelp-to-html $< >$@

# __END__
