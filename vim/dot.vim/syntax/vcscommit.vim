" Vim syntax file
" Language:	VCS commit file
" Maintainer:	Bob Hiestand (bob.hiestand@gmail.com)
" URL:		http://www.zotikos.com/downloads/cvs.vim
" TODO:  Fix URL and last change
" Last Change:	Sat Nov 24 23:25:11 CET 2001

if exists("b:current_syntax")
  finish
endif

syntax region vcsComment start="^VCS: " end="$"
highlight link vcsComment Comment
let b:current_syntax = "vcscommit"
