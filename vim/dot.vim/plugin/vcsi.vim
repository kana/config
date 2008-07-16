" vcsi - Version Control System Interface
" Version: 0.1.0
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
" Intro  "{{{1

if exists('g:loaded_vcsi')
  finish
endif








" Interfaces  "{{{1

command! -bar -complete=file -count=0 -nargs=* VcsiAdd
\       call vcsi#add(<f-args>)
command! -bar -complete=file -count=0 -nargs=* VcsiCommit
\       call vcsi#commit(<f-args>)
command! -bar -complete=file -count=0 -nargs=* VcsiDiff
\       call vcsi#diff(<count>, <f-args>)
command! -bar -complete=file -count=0 -nargs=* VcsiLog
\       call vcsi#log(<f-args>)
command! -bang -bar -complete=file -count=0 -nargs=* VcsiRemove
\       call vcsi#remove('<bang>' == '!', <f-args>)
command! -bar -complete=file -count=0 -nargs=* VcsiRevert
\       call vcsi#revert(<f-args>)
command! -bar -complete=file -count=0 -nargs=* VcsiStatus
\       call vcsi#status(<f-args>)


command! -bang -bar -nargs=0 VcsiDefaultKeyMappings
\       call s:cmd_VcsiDefaultKeyMappings('<bang>' == '!')
function! s:cmd_VcsiDefaultKeyMappings(banged_p)
  let modifier = (a:banged_p ? '' : '<unique>')
  silent! execute 'nmap' modifier '<Leader>vA' '<Plug>(vcsi-add-all)'
  silent! execute 'nmap' modifier '<Leader>va' '<Plug>(vcsi-add-it)'
  silent! execute 'nmap' modifier '<Leader>vC' '<Plug>(vcsi-commit-all)'
  silent! execute 'nmap' modifier '<Leader>vc' '<Plug>(vcsi-commit-it)'
  silent! execute 'nmap' modifier '<Leader>vD' '<Plug>(vcsi-diff-all)'
  silent! execute 'nmap' modifier '<Leader>vd' '<Plug>(vcsi-diff-it)'
  silent! execute 'nmap' modifier '<Leader>vL' '<Plug>(vcsi-log-all)'
  silent! execute 'nmap' modifier '<Leader>vl' '<Plug>(vcsi-log-it)'
  silent! execute 'nmap' modifier '<Leader>vr' '<Plug>(vcsi-remove-it)'
  silent! execute 'nmap' modifier '<Leader>vV' '<Plug>(vcsi-revert-all)'
  silent! execute 'nmap' modifier '<Leader>vv' '<Plug>(vcsi-revert-it)'
  silent! execute 'nmap' modifier '<Leader>vS' '<Plug>(vcsi-status-all)'
  silent! execute 'nmap' modifier '<Leader>vs' '<Plug>(vcsi-status-it)'
  return
endfunction




nnoremap <silent> <Plug>(vcsi-add-all)  :<C-u>VcsiAdd .<Return>
nnoremap <silent> <Plug>(vcsi-commit-all)  :<C-u>VcsiCommit.<Return>
nnoremap <silent> <Plug>(vcsi-diff-all)  :VcsiDiff.<Return>
nnoremap <silent> <Plug>(vcsi-log-all)  :<C-u>VcsiLog.<Return>
nnoremap <silent> <Plug>(vcsi-revert-all)  :<C-u>VcsiRevert.<Return>
nnoremap <silent> <Plug>(vcsi-status-all)  :<C-u>VcsiStatus.<Return>

nnoremap <silent> <Plug>(vcsi-add-it)  :<C-u>VcsiAdd<Return>
nnoremap <silent> <Plug>(vcsi-commit-it)  :<C-u>VcsiCommit<Return>
nnoremap <silent> <Plug>(vcsi-diff-it)  :VcsiDiff<Return>
nnoremap <silent> <Plug>(vcsi-log-it)  :<C-u>VcsiLog<Return>
nnoremap <silent> <Plug>(vcsi-remove-it)  :<C-u>VcsiRemove<Return>
nnoremap <silent> <Plug>(vcsi-revert-it)  :<C-u>VcsiRevert<Return>
nnoremap <silent> <Plug>(vcsi-status-it)  :<C-u>VcsiStatus<Return>


if !exists('g:vcsi_no_default_key_mappings')
  VcsiDefaultKeyMappings
endif








" Variables  "{{{1

if !exists('g:vcsi_diff_in_commit_buffer_p')
  let g:vcsi_diff_in_commit_buffer_p = 0
endif

if !exists('g:vcsi_echo_script_p')
  let g:vcsi_echo_script_p = 1
endif

if !exists('g:vcsi_open_command')
  let g:vcsi_open_command = 'belowright new'
endif
" Don't touch g:vcsi_open_command_{command}.

if !exists('g:vcsi_status_in_commit_buffer_p')
  let g:vcsi_status_in_commit_buffer_p = 0
endif

if !exists('g:vcsi_use_native_message_p')
  let g:vcsi_use_native_message_p = 0
endif








" Fin.  "{{{1

let g:loaded_vcsi = 1








" __END__
" vim: foldmethod=marker
