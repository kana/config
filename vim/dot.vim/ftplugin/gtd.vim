" Vim ftplugin: gtd - Support to do Getting Things Done
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

if exists('b:did_ftplugin')
  finish
endif








nnoremap <Plug>(gtd-new-issue)  :<C-u>call gtd#new_issue()<Return>
nnoremap <Plug>(gtd-new-note)  :<C-u>call gtd#new_note()<Return>
nnoremap <Plug>(gtd-jump-to-issue)  :<C-u>call gtd#jump_to_issue()<Return>
nnoremap <Plug>(gtd-mark-as-inbox)  :<C-u>call gtd#mark('inbox')<Return>
nnoremap <Plug>(gtd-mark-as-next)  :<C-u>call gtd#mark('next')<Return>
nnoremap <Plug>(gtd-mark-as-calendar)  :<C-u>call gtd#mark('calendar')<Return>
nnoremap <Plug>(gtd-mark-as-projects)  :<C-u>call gtd#mark('projects')<Return>
nnoremap <Plug>(gtd-mark-as-waiting)  :<C-u>call gtd#mark('waiting')<Return>
nnoremap <Plug>(gtd-mark-as-someday)  :<C-u>call gtd#mark('someday')<Return>
nnoremap <Plug>(gtd-mark-as-archive)  :<C-u>call gtd#mark('archive')<Return>
nnoremap <Plug>(gtd-mark-as-trash)  :<C-u>call gtd#mark('trash')<Return>








silent! nmap <unique> <buffer> <LocalLeader>i  <Plug>(gtd-new-issue)
silent! nmap <unique> <buffer> <LocalLeader>n  <Plug>(gtd-new-note)
silent! nmap <unique> <buffer> <LocalLeader>g  <Plug>(gtd-jump-to-issue)
silent! nmap <unique> <buffer> <LocalLeader>I  <Plug>(gtd-mark-inbox)
silent! nmap <unique> <buffer> <LocalLeader><Space>  <Plug>(gtd-mark-next)
silent! nmap <unique> <buffer> <LocalLeader>c  <Plug>(gtd-mark-calendar)
silent! nmap <unique> <buffer> <LocalLeader>p  <Plug>(gtd-mark-projects)
silent! nmap <unique> <buffer> <LocalLeader>w  <Plug>(gtd-mark-waiting)
silent! nmap <unique> <buffer> <LocalLeader>s  <Plug>(gtd-mark-someday)
silent! nmap <unique> <buffer> <LocalLeader>a  <Plug>(gtd-mark-archive)
silent! nmap <unique> <buffer> <LocalLeader>t  <Plug>(gtd-mark-trash)


command -buffer GtdInitialize  call gtd#initialize()


setlocal foldmethod=syntax








if !exists('b:undo_ftplugin')
  let b:undo_ftplugin = ''
endif
let b:undo_ftplugin .= '
\ | setlocal foldmethod<
\ | execute "silent! nunmap <buffer> <LocalLeader>i"
\ | execute "silent! nunmap <buffer> <LocalLeader>n"
\ | execute "silent! nunmap <buffer> <LocalLeader>g"
\ | execute "silent! nunmap <buffer> <LocalLeader>I"
\ | execute "silent! nunmap <buffer> <LocalLeader><Space>"
\ | execute "silent! nunmap <buffer> <LocalLeader>c"
\ | execute "silent! nunmap <buffer> <LocalLeader>p"
\ | execute "silent! nunmap <buffer> <LocalLeader>w"
\ | execute "silent! nunmap <buffer> <LocalLeader>s"
\ | execute "silent! nunmap <buffer> <LocalLeader>a"
\ | execute "silent! nunmap <buffer> <LocalLeader>t"
\ '

let b:did_ftplugin = 1

" __END__
" vim: foldmethod=marker
