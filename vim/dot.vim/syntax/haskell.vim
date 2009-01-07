" Vim syntax: haskell
" Version: 0.0.0
" Copyright (C) 2008 kana <http://whileimautomaton.net/>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" This code is based on $VIMRUNTIME/syntax/haskell.vim
" and modified to cooperate with $VIMRUNTIME/autoload/syntaxcomplete.vim.
if exists('b:current_syntax')  "{{{1
  finish
endif
let b:current_syntax = 'haskell'




" Haskell part  "{{{1

" (Qualified) identifiers (no default highlighting)
syntax match haskellConId "\(\<[A-Z][a-zA-Z0-9_']*\.\)\=\<[A-Z][a-zA-Z0-9_']*\>"
syntax match haskellVarId "\(\<[A-Z][a-zA-Z0-9_']*\.\)\=\<[a-z][a-zA-Z0-9_']*\>"

" Infix operators--most punctuation characters and any (qualified) identifier
" enclosed in `backquotes`. An operator starting with : is a constructor,
" others are variables (e.g. functions).
syntax match haskellVarSym "\(\<[A-Z][a-zA-Z0-9_']*\.\)\=[-!#$%&\*\+/<=>\?@\\^|~.][-!#$%&\*\+/<=>\?@\\^|~:.]*"
syntax match haskellConSym "\(\<[A-Z][a-zA-Z0-9_']*\.\)\=:[-!#$%&\*\+./<=>\?@\\^|~:]*"
syntax match haskellVarSym "`\(\<[A-Z][a-zA-Z0-9_']*\.\)\=[a-z][a-zA-Z0-9_']*`"
syntax match haskellConSym "`\(\<[A-Z][a-zA-Z0-9_']*\.\)\=[A-Z][a-zA-Z0-9_']*`"

" Reserved symbols--cannot be overloaded.
syntax match haskellDelimiter "(\|)\|\[\|\]\|,\|;\|_\|{\|}"

" Strings and constants
syntax match haskellSpecialChar contained "\\\([0-9]\+\|o[0-7]\+\|x[0-9a-fA-F]\+\|[\"\\'&\\abfnrtv]\|^[A-Z^_\[\\\]]\)"
syntax keyword haskellSpecialChar contained NUL SOH STX ETX EOT ENQ ACK BEL BS HT LF VT FF CR SO SI DLE DC1 DC2 DC3 DC4 NAK SYN ETB CAN EM SUB ESC FS GS RS US SP DEL
syntax match haskellSpecialCharError contained "\\&\|'''\+"
syntax region haskellString start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=haskellSpecialChar
syntax match haskellCharacter "[^a-zA-Z0-9_']'\([^\\]\|\\[^']\+\|\\'\)'"lc=1 contains=haskellSpecialChar,haskellSpecialCharError
syntax match haskellCharacter "^'\([^\\]\|\\[^']\+\|\\'\)'" contains=haskellSpecialChar,haskellSpecialCharError
syntax match haskellNumber "\<[0-9]\+\>\|\<0[xX][0-9a-fA-F]\+\>\|\<0[oO][0-7]\+\>"
syntax match haskellFloat "\<[0-9]\+\.[0-9]\+\([eE][-+]\=[0-9]\+\)\=\>"

" Keyword definitions. These must be patters instead of keywords
" because otherwise they would match as keywords at the start of a
" "literate" comment (see lhs.vim).
syntax keyword haskellModule module
syntax keyword haskellImport import
syntax keyword haskellImportMod containedin=haskellImport as qualified hiding
syntax keyword haskellInfix infix infixl infixr
syntax keyword haskellStructure class data deriving instance default where
syntax keyword haskellTypedef type newtype
syntax keyword haskellStatement do case of let in
syntax keyword haskellConditional if then else

" Not real keywords, but close.
if exists("haskell_highlight_boolean")
  " Boolean constants from the standard prelude.
  syntax keyword haskellBoolean True False
endif
if exists("haskell_highlight_types")
  " Primitive types from the standard prelude and libraries.
  syntax keyword haskellType Int Integer Char Bool Float Double IO Void Addr Array String
endif
if exists("haskell_highlight_more_types")
  " Types from the standard prelude libraries.
  syntax keyword haskellType Maybe Either Ratio Complex Ordering IOError IOResult ExitCode
  syntax keyword haskellMaybe Nothing
  syntax keyword haskellExitCode ExitSuccess
  syntax keyword haskellOrdering GT LT EQ
endif
if exists("haskell_highlight_debug")
  " Debugging functions from the standard prelude.
  syntax keyword haskellDebug undefined error trace
endif

" Comments
syntax match haskellLineComment "---*\([^-!#$%&\*\+./<=>\?@\\^|~].*\)\?$"
syntax region haskellBlockComment start="{-" end="-}" contains=haskellBlockComment
syntax region haskellPragma start="{-#" end="#-}"




" C directives  "{{{1

" C Preprocessor directives. Shamelessly ripped from c.vim and trimmed
" First, see whether to flag directive-like lines or not
if (!exists("haskell_allow_hash_operator"))
  syntax match cError display "^\s*\(%:\|#\).*$"
endif

" Accept %: for # (C99)
syntax region cPreCondit start="^\s*\(%:\|#\)\s*\(if\|ifdef\|ifndef\|elif\)\>" skip="\\$" end="$" end="//"me=s-1 contains=cComment,cCppString,cCommentError
syntax match cPreCondit display "^\s*\(%:\|#\)\s*\(else\|endif\)\>"
syntax region cCppOut start="^\s*\(%:\|#\)\s*if\s\+0\+\>" end=".\@=\|$" contains=cCppOut2
syntax region cCppOut2 contained start="0" end="^\s*\(%:\|#\)\s*\(endif\>\|else\>\|elif\>\)" contains=cCppSkip
syntax region cCppSkip contained start="^\s*\(%:\|#\)\s*\(if\>\|ifdef\>\|ifndef\>\)" skip="\\$" end="^\s*\(%:\|#\)\s*endif\>" contains=cCppSkip
syntax region cIncluded display contained start=+"+ skip=+\\\\\|\\"+ end=+"+
syntax match cIncluded display contained "<[^>]*>"
syntax match cInclude display "^\s*\(%:\|#\)\s*include\>\s*["<]" contains=cIncluded
syntax cluster cPreProcGroup contains=cPreCondit,cIncluded,cInclude,cDefine,cCppOut,cCppOut2,cCppSkip,cCommentStartError
syntax region cDefine matchgroup=cPreCondit start="^\s*\(%:\|#\)\s*\(define\|undef\)\>" skip="\\$" end="$"
syntax region cPreProc matchgroup=cPreCondit start="^\s*\(%:\|#\)\s*\(pragma\>\|line\>\|warning\>\|warn\>\|error\>\)" skip="\\$" end="$" keepend

syntax region cComment matchgroup=cCommentStart start="/\*" end="\*/" contains=cCommentStartError,cSpaceError contained
syntax match cCommentError display "\*/" contained
syntax match cCommentStartError display "/\*"me=e-1 contained
syntax region cCppString start=+L\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=cSpecial contained




" Highlight links  "{{{1

highlight def link haskellModule haskellStructure
highlight def link haskellImport Include
highlight def link haskellImportMod haskellImport
highlight def link haskellInfix PreProc
highlight def link haskellStructure Structure
highlight def link haskellStatement Statement
highlight def link haskellConditional Conditional
highlight def link haskellSpecialChar SpecialChar
highlight def link haskellTypedef Typedef
highlight def link haskellVarSym haskellOperator
highlight def link haskellConSym haskellOperator
highlight def link haskellOperator Operator
if exists("haskell_highlight_delimiters")
  " Some people find this highlighting distracting.
  highlight def link haskellDelimiter Delimiter
endif
highlight def link haskellSpecialCharError Error
highlight def link haskellString String
highlight def link haskellCharacter Character
highlight def link haskellNumber Number
highlight def link haskellFloat Float
highlight def link haskellConditional Conditional
highlight def link haskellLiterateComment haskellComment
highlight def link haskellBlockComment haskellComment
highlight def link haskellLineComment haskellComment
highlight def link haskellComment Comment
highlight def link haskellPragma SpecialComment
highlight def link haskellBoolean Boolean
highlight def link haskellType Type
highlight def link haskellMaybe haskellEnumConst
highlight def link haskellOrdering haskellEnumConst
highlight def link haskellEnumConst Constant
highlight def link haskellDebug Debug

highlight def link cCppString haskellString
highlight def link cCommentStart haskellComment
highlight def link cCommentError haskellError
highlight def link cCommentStartError haskellError
highlight def link cInclude Include
highlight def link cPreProc PreProc
highlight def link cDefine Macro
highlight def link cIncluded haskellString
highlight def link cError Error
highlight def link cPreCondit PreCondit
highlight def link cComment Comment
highlight def link cCppSkip cCppOut
highlight def link cCppOut2 cCppOut
highlight def link cCppOut Comment




" __END__  "{{{1
" vim: foldmethod=marker
