" vcsi.vim - Version Control System Interface
" Version: 0.0.2
" Copyright: Copyright (C) 2007-2008 kana <http://nicht.s8.xrea.com/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
" $Id$  "{{{1

if exists('g:loaded_vcsi')
  finish
endif








" Interfaces  "{{{1

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
