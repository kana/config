" Vim ftpluing file
" Language:	issue (my personal issue tracking memo)
" Maintainer:	kana <http://nicht.s8.xrea.com>
" Last Change:	$Id$

if exists('b:did_ftplugin')
  finish
endif




nnoremap <LocalLeader>s  :<C-u>call <SID>ShowStatus()<Return>

"" Moving around elements (just a memo; not implemented yet).
" nnoremap <buffer> <LocalLeader>j  :<C-u>call <SID>MoveNextIssue()<Return>
" nnoremap <buffer> <LocalLeader>k  :<C-u>call <SID>MovePrevIssue()<Return>
" nnoremap <buffer> <LocalLeader>tj  :<C-u>call <SID>MoveNextItem()<Return>
" nnoremap <buffer> <LocalLeader>tk  :<C-u>call <SID>MovePrevItem()<Return>
" nnoremap <buffer> <LocalLeader>gj  :<C-u>call <SID>MoveNextGroup()<Return>
" nnoremap <buffer> <LocalLeader>gk  :<C-u>call <SID>MovePrevGroup()<Return>




function! s:ShowStatus()
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

  echo 'Issue Status:' 'Next ID:' max_id+1 '/' 'Count:' sum

  call setpos('.', pos)
endfunction




setlocal foldmethod=syntax

let b:did_ftplugin = 1

" __END__
