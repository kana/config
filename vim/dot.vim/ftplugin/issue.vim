" Vim ftplugin: issue - my personal issue tracking memo
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
" Misc. initialization  "{{{1

if exists('b:did_ftplugin')
  finish
endif


setlocal foldmethod=syntax


let s:RE_ISSUE_ID = '#\<\d\+\>'








" Key mappings  "{{{1

nnoremap <buffer> <Plug>(issue-show-status)  :<C-u>call <SID>ShowStatus()<Return>
nnoremap <buffer> <Plug>(issue-new-issue)  :<C-u>call <SID>NewIssue()<Return>
nnoremap <buffer> <Plug>(issue-new-note)  :<C-u>call <SID>NewNote()<Return>
nnoremap <buffer> <Plug>(issue-jump-to-issue)  :<C-u>call <SID>JumpToIssue()<Return>

silent! nmap <unique> <buffer> <LocalLeader>s  <Plug>(issue-show-status)
silent! nmap <unique> <buffer> <LocalLeader>i  <Plug>(issue-new-issue)
silent! nmap <unique> <buffer> <LocalLeader>n  <Plug>(issue-new-note)
silent! nmap <unique> <buffer> <Return>  <Plug>(issue-jump-to-issue)

call textobj#user#plugin('issue', {
\      'id': {
\        '*pattern*': s:RE_ISSUE_ID,
\        'move-n': '<buffer> <LocalLeader>j',
\        'move-p': '<buffer> <LocalLeader>k',
\        'move-N': '<buffer> <LocalLeader>J',
\        'move-P': '<buffer> <LocalLeader>K',
\      },
\    })

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
  if search(s:RE_ISSUE_ID, 'cW') == 0
    echo 'There is no issue id in this buffer.'
    return 0
  endif

  let id_string = matchstr(getline('.'), s:RE_ISSUE_ID)
  if search('^' . id_string . '\>', 'cw') == 0
    echo 'There is no issue for this id.'
    return 0
  endif

  normal! zv
  return !0
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

let b:undo_ftplugin = 'setlocal foldmethod<
                     \|silent! nunmap <buffer> <LocalLeader>J
                     \|silent! nunmap <buffer> <LocalLeader>K
                     \|silent! nunmap <buffer> <LocalLeader>i
                     \|silent! nunmap <buffer> <LocalLeader>j
                     \|silent! nunmap <buffer> <LocalLeader>k
                     \|silent! nunmap <buffer> <LocalLeader>n
                     \|silent! nunmap <buffer> <LocalLeader>s
                     \|silent! nunmap <buffer> <Return>
                     \'
let b:did_ftplugin = 1








" __END__  "{{{1
" vim: foldmethod=marker
