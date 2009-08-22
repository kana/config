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




" Named key mappings:
" FIXME: Should these definitions be put into plugin/gtd.vim or not?
nnoremap <silent> <Plug>(gtd-new-issue)  :<C-u>call gtd#new_issue()<Return>
nnoremap <silent> <Plug>(gtd-new-note)  :<C-u>call gtd#new_note()<Return>
nnoremap <silent> <Plug>(gtd-jump-to-issue)
\                 :<C-u>call gtd#jump_to_issue()<Return>
nnoremap <silent> <Plug>(gtd-mark-as-inbox)
\                 :<C-u>call gtd#mark('INBOX')<Return>
nnoremap <silent> <Plug>(gtd-mark-as-next-actions)
\                 :<C-u>call gtd#mark('NEXT ACTIONS')<Return>
nnoremap <silent> <Plug>(gtd-mark-as-calendar)
\                 :<C-u>call gtd#mark('CALENDAR')<Return>
nnoremap <silent> <Plug>(gtd-mark-as-projects)
\                 :<C-u>call gtd#mark('PROJECTS')<Return>
nnoremap <silent> <Plug>(gtd-mark-as-waiting-for)
\                 :<C-u>call gtd#mark('WAITING FOR')<Return>
nnoremap <silent> <Plug>(gtd-mark-as-someday)
\                 :<C-u>call gtd#mark('SOMEDAY')<Return>
nnoremap <silent> <Plug>(gtd-mark-as-archive)
\                 :<C-u>call gtd#mark('ARCHIVE')<Return>
nnoremap <silent> <Plug>(gtd-mark-as-trash)
\                 :<C-u>call gtd#mark('TRASH')<Return>


" Default key mappings:
silent! nmap <unique> <buffer> <LocalLeader>i  <Plug>(gtd-new-issue)
silent! nmap <unique> <buffer> <LocalLeader>n  <Plug>(gtd-new-note)
silent! nmap <unique> <buffer> <LocalLeader>g  <Plug>(gtd-jump-to-issue)
silent! nmap <unique> <buffer> <LocalLeader>I  <Plug>(gtd-mark-as-inbox)
silent! nmap <unique> <buffer> <LocalLeader><Space>
\                              <Plug>(gtd-mark-as-next-actions)
silent! nmap <unique> <buffer> <LocalLeader>c  <Plug>(gtd-mark-as-calendar)
silent! nmap <unique> <buffer> <LocalLeader>p  <Plug>(gtd-mark-as-projects)
silent! nmap <unique> <buffer> <LocalLeader>w  <Plug>(gtd-mark-as-waiting-for)
silent! nmap <unique> <buffer> <LocalLeader>s  <Plug>(gtd-mark-as-someday)
silent! nmap <unique> <buffer> <LocalLeader>a  <Plug>(gtd-mark-as-archive)
silent! nmap <unique> <buffer> <LocalLeader>t  <Plug>(gtd-mark-as-trash)


" Options:
setlocal foldmethod=syntax


" Initial setup:
if line('$') == 1 && getline(1) == ''  " empty buffer?
  call gtd#initialize()
endif




if !exists('b:undo_ftplugin')
  let b:undo_ftplugin = ''
endif
  " FIXME: Overridden default key mappings should not be "undone".
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
