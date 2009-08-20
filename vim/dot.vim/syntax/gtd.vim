" Vim syntax: gtd - Support to do Getting Things Done
" Version: 0.0.0
" Copyright (C) 2009 kana <http://whileimautomaton.net/>
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

if exists('b:current_syntax')
  finish
endif

syntax clear

syntax case match




syntax match gtdNoteDatetime /^\t\zs\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d$/
syntax region gtdSection
\ start=/^[A-Z ]\+$/
\ end=/\n\ze\(;\|[A-Z ]\+\)$/
\ contains=ALLBUT,gtdSection
\ fold
\ transparent




highlight def link gtdSection Normal
highlight def link gtdSectionTitle PreProc
highlight def link gtdComment Comment
highlight def link gtdIssue Normal
highlight def link gtdIssueTitle Label
highlight def link gtdIssueTag Type
highlight def link gtdIssueId Label
highlight def link gtdNoteDatetime Constant




let b:current_syntax = 'gtd'

" __END__
" vim: foldmethod=marker
