" Vim syntax file
" Language: BUGS
" Maintainer: kana <http://nicht.s8.xrea.com/>
" Last Change: $Date: 2006/09/23 02:02:54 $
" Remark: Just for me.
" Id: $Id$

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syntax case ignore




syntax match bugsTitle /^\t*\<[^\t]\+\>\(\t[0-9A-Z:+-]\+$\)\@=/
syntax match bugsDatetime /\(\t\)\@<=\<\d\d\d\d-\d\d-\d\d[^\t]*\>$/

highlight link bugsTitle Label
highlight link bugsDatetime Number

let b:current_syntax = "bugs"
" vim: et sts=2 sw=2
