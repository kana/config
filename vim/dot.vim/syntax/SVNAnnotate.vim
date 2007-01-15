" Vim syntax file
" Language:	SVN annotate output
" Maintainer:	Bob Hiestand <bob.hiestand@gmail.com>
" Last Change:	2006/05/31
" Remark:	Used by the vcscommand plugin.
if exists("b:current_syntax")
  finish
endif

syn match svnName /\S\+/ contained
syn match svnVer /^\s\+\d\+/ contained nextgroup=svnName skipwhite
syn match svnHead /^\s\+\d\+\s\+\S\+/ contains=svnVer,svnName

if !exists("did_svnannotate_syntax_inits")
  let did_svnannotate_syntax_inits = 1
  hi link svnName Type
  hi link svnVer Statement
endif

let b:current_syntax="svnAnnotate"
