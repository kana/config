" Vim syntax file
" Language:	issue (my personal issue tracking memo)
" Maintainer:	kana <http://nicht.s8.xrea.com/>
" Last Change:	$Id$

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
execute 'syntax match issueTitle /'.s:RE_TITLE.'/'

syntax match issueItemDatetime '^\t\zs\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d\ze'

" issueInvalidTag is the fallback, so it must be placed at first.
syntax match issueInvalidTag '\[[A-Za-z0-9._-]*\]'
syntax match issueStateTag '\[\%(defered\|done\|pending\|planned\|working\)\]'
syntax match issueValidTag
     \ '\[\%(\d\+\.\d\+\%(\.\d\+\|[ab]\d\+\)\?\|devnote\)\]'


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
hi def link issueItemDatetime Constant
hi def link issueComment Comment
hi def link issueStateTag Type
hi def link issueValidTag Special
hi def link issueInvalidTag Error




let b:current_syntax = 'issue'

" __END__
