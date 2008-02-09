" Vim ftpluing file
" Language:	issue (my personal issue tracking memo)
" Maintainer:	kana <http://nicht.s8.xrea.com>
" Last Change:	$Id$
" Misc. initialization  "{{{1

if exists('b:did_ftplugin')
  finish
endif


setlocal foldmethod=syntax


let s:RE_ISSUE_ID = '#\<\d\+\>'








" Key mappings  "{{{1

nnoremap <buffer> <LocalLeader>s  :<C-u>call <SID>ShowStatus()<Return>

nnoremap <buffer> <LocalLeader>i  :<C-u>call <SID>NewIssue()<Return>
nnoremap <buffer> <LocalLeader>n  :<C-u>call <SID>NewNote()<Return>

nnoremap <buffer> <Return>  :<C-u>call <SID>JumpToIssue()<Return>

call textobj#user#define(s:RE_ISSUE_ID, '', '', {
   \                       'move-to-next': '<LocalLeader>j',
   \                       'move-to-prev': '<LocalLeader>k',
   \                     })

"" Moving around elements (just a memo; not implemented yet).
""
"" But recently (2007-09-18T22:05:50),
"" I feel that zj/zk (moving around folds) is enough for this purpose.
" nnoremap <buffer> <LocalLeader>j  :<C-u>call <SID>MoveNextIssue()<Return>
" nnoremap <buffer> <LocalLeader>k  :<C-u>call <SID>MovePrevIssue()<Return>
" nnoremap <buffer> <LocalLeader>tj  :<C-u>call <SID>MoveNextNote()<Return>
" nnoremap <buffer> <LocalLeader>tk  :<C-u>call <SID>MovePrevNote()<Return>
" nnoremap <buffer> <LocalLeader>gj  :<C-u>call <SID>MoveNextGroup()<Return>
" nnoremap <buffer> <LocalLeader>gk  :<C-u>call <SID>MovePrevGroup()<Return>








" Functions  "{{{1

function! s:ShowStatus()
  let [max_id, sum] = s:GetIDInfo()
  echo 'Issue Status:' 'Next ID:' max_id+1 '/' 'Count:' sum
endfunction




function! s:NewIssue()
  let [max_id, sum] = s:GetIDInfo()
  let new_id = (max_id + 1)
  normal! ggzv
  call search('\V; ++ NEW ISSUES ++', 'cW')
  call append(line('.'), '#'.new_id.' ')
  normal! j
  startinsert!
endfunction


" Assumptions: The cursor is inside an issue, i.e.,
" between the title of an issue and the previous line of the next issue.
function! s:NewNote()
  call search('^#\(\d\+\) ', 'bcW')
  call append('.', ["\t".strftime('%Y-%m-%dT%H:%M:%S'), "\t\t", ''])
  normal! jj
  startinsert!
endfunction




function! s:JumpToIssue()
  echo 'FIXME: Not Implemented Yet.'
  return
  let BAD = [0, 0]
  let pos = [line('.'), col('.')]

  let fb = textobj#user#move(s:RE_ISSUE_ID, 'n')
  let fe = textobj#user#move(s:RE_ISSUE_ID, 'ne')
  let fdiff = s:Distance(pos, fb, fe)

  let bb = textobj#user#move(s:RE_ISSUE_ID, 'nb')
  let be = textobj#user#move(s:RE_ISSUE_ID, 'nbe')
  let bdiff = s:Distance(pos, bb, be)

  if fdiff != BAD && bdiff != BAD
    if s:LT(fdiff, bdiff)
    endif
  elseif fdiff != BAD && bdiff == BAD
  elseif fdiff == BAD && bdiff != BAD
  else  " if fdiff == BAD && bdiff == BAD
    " nop
  endif
endfunction




function! s:GetIDInfo()
  let pos = getpos('.')

  let max_id = 0
  let sum = 0
  global/^#/
    \ let line = getline('.')
    \
    \ | let sum = sum + 1
    \
    \ | let id = str2nr(matchstr(line, '^#\zs\d\+\ze'))
    \ | let max_id = max_id < id ? id : max_id

  call setpos('.', pos)

  return [max_id, sum]
endfunction








" Misc. finalization "{{{1

let b:did_ftplugin = 1

" __END__
" vim: foldmethod=marker
