" Vim syntax: issue - my personal issue tracking memo
" Copyright (C) 2007-2008 kana <http://whileimautomaton.net/>
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
"
" Structure:
"
"   GROUP1
"   ======
"
"   GROUP2
"   ------
"
"   GROUP3
"   ``````
"
"   #1 issue
"           2007-09-18T22:15:47
"                   Note

if exists('b:current_syntax')
  finish
endif

syntax clear
syntax sync fromstart




let s:GROUP1_BORDER = '\%(=\+$\)'
let s:GROUP2_BORDER = '\%(-\+$\)'
let s:GROUP3_BORDER = '\%(`\+$\)'
let s:GROUP12_BORDER = '\%([=-]\+$\)'
let s:GROUP123_BORDER = '\%([=`-]\+$\)'
let s:TITLE = '\%(^[^;\t][^\t]*\)'

let s:RE_GROUP1_HEADER = s:TITLE.'\n'.s:GROUP1_BORDER
let s:RE_GROUP2_HEADER = s:TITLE.'\n'.s:GROUP2_BORDER
let s:RE_GROUP3_HEADER = s:TITLE.'\n'.s:GROUP3_BORDER
let s:RE_GROUP12_HEADER = s:TITLE.'\n'.s:GROUP12_BORDER
let s:RE_GROUP123_HEADER = s:TITLE.'\n'.s:GROUP123_BORDER
let s:RE_TITLE = '\zs'.s:TITLE.'\ze\%(\t.*\)\?\n\%('.s:GROUP123_BORDER.'\)\@!'




syntax match issueComment '^;.*$'
execute 'syntax match issueGroup1Header /'.s:RE_GROUP1_HEADER.'/'
execute 'syntax match issueGroup2Header /'.s:RE_GROUP2_HEADER.'/'
execute 'syntax match issueGroup3Header /'.s:RE_GROUP3_HEADER.'/'
execute 'syntax match issueTitle /'.s:RE_TITLE.'/ contains=issueCategories'
  " FIXME: the following pattern is incomplete.
  " it must be prefixed with /^#/, but doesn't work correctly.
syntax match issueCategories /\d\+\zs\%( [a-z0-9]\+:\)\+\ze / contained

syntax match issueNoteDatetime '^\t\zs\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\ze'


execute 'syntax region issueFoldByGroup1 keepend'
      \ 'start=/'.s:RE_GROUP1_HEADER.'/'
      \ 'end=/\n\ze'.s:RE_GROUP1_HEADER.'/'
      \ 'transparent fold'
execute 'syntax region issueFoldByGroup2 keepend'
      \ 'start=/'.s:RE_GROUP2_HEADER.'/'
      \ 'end=/\n\ze'.s:RE_GROUP12_HEADER.'/'
      \ 'transparent fold'
execute 'syntax region issueFoldByGroup3 keepend'
      \ 'start=/'.s:RE_GROUP3_HEADER.'/'
      \ 'end=/\n\ze'.s:RE_GROUP123_HEADER.'/'
      \ 'transparent fold'
execute 'syntax region issueFoldByIssue keepend'
      \ 'start=/'.s:RE_TITLE.'/'
      \ 'end=/\n\ze[^\t]/'
      \ 'transparent fold'




hi def link issueGroup1Header PreProc
hi def link issueGroup2Header PreProc
hi def link issueGroup3Header PreProc
hi def link issueTitle Label
hi def link issueCategories Type
hi def link issueNoteDatetime Constant
hi def link issueComment Comment




let b:current_syntax = 'issue'

" __END__
" vim: foldmethod=marker
