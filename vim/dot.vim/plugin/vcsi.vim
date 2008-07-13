" vcsi - Version Control System Interface
" Version: 0.0.7
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

command! -bang -bar -count=0 -nargs=0 VcsiBranchList
      \ call vcsi#branch_list('<bang>' == '!')
command! -bang -bar -complete=custom,vcsi#complete_branch_names -count=0
      \ -nargs=? VcsiBranchSwitch
      \ call vcsi#branch_switch('<bang>' == '!', <q-args>)
command! -bar -complete=file -count=0 -nargs=* VcsiCommit
      \ call vcsi#commit(<f-args>)
command! -bar -complete=file -count=0 -nargs=* VcsiDiff
      \ call vcsi#diff(<f-args>)
command! -bar -complete=file -count=0 -nargs=* VcsiInfo
      \ call vcsi#info(<f-args>)
command! -bar -complete=file -count=0 -nargs=* VcsiLog
      \ call vcsi#log(<f-args>)
command! -bar -complete=file -count=0 -nargs=* VcsiPropedit
      \ call vcsi#propedit(<f-args>)
command! -bar -complete=file -count=0 -nargs=* VcsiRevert
      \ call vcsi#revert(<f-args>)
command! -bar -complete=file -count=0 -nargs=* VcsiStatus
      \ call vcsi#status(<f-args>)

command! -bang -bar -nargs=0 VcsiDefaultKeyMappings
      \ call s:default_key_mappings('<bang>' == '!')
function! s:default_key_mappings(bangedp)
  let modifier = (a:bangedp ? '' : '<unique>')
  silent! execute 'nmap' modifier '<Leader>vbL  <Plug>(vcsi-branch-list!)'
  silent! execute 'nmap' modifier '<Leader>vbl  <Plug>(vcsi-branch-list)'
  silent! execute 'nmap' modifier '<Leader>vbS  <Plug>(vcsi-branch-switch!)'
  silent! execute 'nmap' modifier '<Leader>vbs  <Plug>(vcsi-branch-switch)'
  silent! execute 'nmap' modifier '<Leader>vC  <Plug>(vcsi-commit-all)'
  silent! execute 'nmap' modifier '<Leader>vc  <Plug>(vcsi-commit-it)'
  silent! execute 'nmap' modifier '<Leader>vD  <Plug>(vcsi-diff-all)'
  silent! execute 'nmap' modifier '<Leader>vd  <Plug>(vcsi-diff-it)'
  silent! execute 'nmap' modifier '<Leader>vI  <Plug>(vcsi-info-all)'
  silent! execute 'nmap' modifier '<Leader>vi  <Plug>(vcsi-info-it)'
  silent! execute 'nmap' modifier '<Leader>vL  <Plug>(vcsi-log-all)'
  silent! execute 'nmap' modifier '<Leader>vl  <Plug>(vcsi-log-it)'
  silent! execute 'nmap' modifier '<Leader>vR  <Plug>(vcsi-revert-all)'
  silent! execute 'nmap' modifier '<Leader>vr  <Plug>(vcsi-revert-it)'
  silent! execute 'nmap' modifier '<Leader>vS  <Plug>(vcsi-status-all)'
  silent! execute 'nmap' modifier '<Leader>vs  <Plug>(vcsi-status-it)'
  return
endfunction




nnoremap <silent> <Plug>(vcsi-branch-list!)  :<C-u>VcsiBranchList!<Return>
nnoremap <silent> <Plug>(vcsi-branch-list)  :<C-u>VcsiBranchList<Return>
nnoremap <silent> <Plug>(vcsi-branch-switch!)  :<C-u>VcsiBranchSwitch!<Return>
nnoremap <silent> <Plug>(vcsi-branch-switch)  :<C-u>VcsiBranchSwitch<Return>

nnoremap <silent> <Plug>(vcsi-commit-all)  :<C-u>VcsiCommit all<Return>
nnoremap <silent> <Plug>(vcsi-diff-all)  :<C-u>VcsiDiff all<Return>
nnoremap <silent> <Plug>(vcsi-info-all)  :<C-u>VcsiInfo all<Return>
nnoremap <silent> <Plug>(vcsi-log-all)  :<C-u>VcsiLog all<Return>
nnoremap <silent> <Plug>(vcsi-propedit-all)  :<C-u>VcsiPropedit all<Return>
nnoremap <silent> <Plug>(vcsi-revert-all)  :<C-u>VcsiRevert all<Return>
nnoremap <silent> <Plug>(vcsi-status-all)  :<C-u>VcsiStatus all<Return>

nnoremap <silent> <Plug>(vcsi-commit-it)  :<C-u>VcsiCommit -<Return>
nnoremap <silent> <Plug>(vcsi-diff-it)  :<C-u>VcsiDiff -<Return>
nnoremap <silent> <Plug>(vcsi-info-it)  :<C-u>VcsiInfo -<Return>
nnoremap <silent> <Plug>(vcsi-log-it)  :<C-u>VcsiLog -<Return>
nnoremap <silent> <Plug>(vcsi-propedit-it)  :<C-u>VcsiPropedit -<Return>
nnoremap <silent> <Plug>(vcsi-revert-it)  :<C-u>VcsiRevert -<Return>
nnoremap <silent> <Plug>(vcsi-status-it)  :<C-u>VcsiStatus -<Return>

if !exists('g:vcsi_no_default_key_mappings')
  VcsiDefaultKeyMappings
endif








" Variables  "{{{1

if !exists('g:vcsi_echo_scriptp')
  let g:vcsi_echo_scriptp = 1
endif

if !exists('g:vcsi_diff_in_commit_logp')
  let g:vcsi_diff_in_commit_logp = 0
endif

if !exists('g:vcsi_open_command')
  let g:vcsi_open_command = 'belowright new'
endif

if !exists('g:vcsi_status_in_commit_logp')
  let g:vcsi_status_in_commit_logp = 0
endif








" Fin.  "{{{1

let g:loaded_vcsi = 1








" __END__
" vim: foldmethod=marker
