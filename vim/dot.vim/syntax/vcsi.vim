" Vim syntax: vcsi - Version Control System Interface
" Version: 0.0.7
" Copyright: Copyright (C) 2007-2008 kana <http://whileimautomaton.net/>
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

if version < 600
  syntax clear
elseif exists('b:current_syntax') && b:current_syntax =~# '\<vcsi\>'
  finish
endif




syntax region vcsiLog keepend start=/^\%^/ end=/^=== .* ===$/me=s-1
syntax match vcsiSeparator /^=== .* ===$/

highlight default link vcsiLog Normal
highlight default link vcsiSeparator Delimiter




if !exists('b:current_syntax')
  let b:current_syntax = 'vcsi'
else
  let b:current_syntax .= '.vcsi'
endif

" __END__
