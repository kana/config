" stackreg - Vz-like stackable registers
" Version: 0.0.0
" Copyright (C) 2008 kana <http://whileimautomaton.net/>
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

if exists('g:loaded_stackreg')
  finish
endif




call advice#define('D', 'nv', 'D', 0, '')
call advice#define('Del', 'v', "\<Del>", 0, '')
call advice#define('X', 'v', 'X', 0, '')
call advice#define('d', 'n', 'd', 0, 'operator')
call advice#define('d', 'v', 'd', 0, '')
call advice#define('dd', 'n', 'dd', 0, '')
call advice#define('x', 'v', 'x', 0, '')
call advice#add('D', 'nv', 'after', 'stackreg', 'stackreg#push')
call advice#add('Del', 'v', 'after', 'stackreg', 'stackreg#push')
call advice#add('X', 'v', 'after', 'stackreg', 'stackreg#push')
call advice#add('d', 'nv', 'after', 'stackreg', 'stackreg#push')
call advice#add('dd', 'n', 'after', 'stackreg', 'stackreg#push')
call advice#add('x', 'v', 'after', 'stackreg', 'stackreg#push')


call advice#define('Y', 'nv', 'Y', 0, '')
call advice#define('y', 'n', 'y', 0, 'operator')
call advice#define('y', 'v', 'y', 0, '')
call advice#define('yy', 'n', 'yy', 0, '')
call advice#add('Y', 'nv', 'after', 'stackreg', 'stackreg#push')
call advice#add('y', 'nv', 'after', 'stackreg', 'stackreg#push')
call advice#add('yy', 'n', 'after', 'stackreg', 'stackreg#push')


call advice#define('P', 'nv', 'P', 0, '')
call advice#define('[P', 'n', 'P', 0, '')
call advice#define('[p', 'n', 'p', 0, '')
call advice#define(']P', 'n', 'P', 0, '')
call advice#define(']p', 'n', 'p', 0, '')
call advice#define('gP', 'n', 'P', 0, '')
call advice#define('gp', 'n', 'p', 0, '')
call advice#define('p', 'nv', 'p', 0, '')
call advice#add('P', 'nv', 'before', 'stackreg', 'stackreg#pop')
call advice#add('[P', 'n', 'before', 'stackreg', 'stackreg#pop')
call advice#add('[p', 'n', 'before', 'stackreg', 'stackreg#pop')
call advice#add(']P', 'n', 'before', 'stackreg', 'stackreg#pop')
call advice#add(']p', 'n', 'before', 'stackreg', 'stackreg#pop')
call advice#add('gP', 'n', 'before', 'stackreg', 'stackreg#pop')
call advice#add('gp', 'n', 'before', 'stackreg', 'stackreg#pop')
call advice#add('p', 'nv', 'before', 'stackreg', 'stackreg#pop')




command! -bang -bar -nargs=0 StackregDefaultKeyMappings
\ call s:default_key_mappings('<bang>' == '!')

function! s:default_key_mappings(banged_p)
  let _ = a:banged_p ? '' : '<unique>'

  silent! execute 'nmap' _ 'D  <Plug>(adviced-D)'
  silent! execute 'nmap' _ 'd  <Plug>(adviced-d)'
  silent! execute 'nmap' _ 'dd  <Plug>(adviced-dd)'
  silent! execute 'vmap' _ '<Del>  <Plug>(adviced-Del)'
  silent! execute 'vmap' _ 'D  <Plug>(adviced-D)'
  silent! execute 'vmap' _ 'X  <Plug>(adviced-X)'
  silent! execute 'vmap' _ 'd  <Plug>(adviced-d)'
  silent! execute 'vmap' _ 'x  <Plug>(adviced-x)'

  silent! execute 'nmap' _ 'Y  <Plug>(adviced-Y)'
  silent! execute 'nmap' _ 'y  <Plug>(adviced-y)'
  silent! execute 'nmap' _ 'yy  <Plug>(adviced-yy)'
  silent! execute 'vmap' _ 'Y  <Plug>(adviced-Y)'
  silent! execute 'vmap' _ 'y  <Plug>(adviced-y)'

  silent! execute 'nmap' _ 'P  <Plug>(adviced-P)'
  silent! execute 'nmap' _ '[P  <Plug>(adviced-[P)'
  silent! execute 'nmap' _ '[p  <Plug>(adviced-[p)'
  silent! execute 'nmap' _ ']P  <Plug>(adviced-]P)'
  silent! execute 'nmap' _ ']p  <Plug>(adviced-]p)'
  silent! execute 'nmap' _ 'gP  <Plug>(adviced-gP)'
  silent! execute 'nmap' _ 'gp  <Plug>(adviced-gp)'
  silent! execute 'nmap' _ 'p  <Plug>(adviced-p)'
  silent! execute 'vmap' _ 'P  <Plug>(adviced-P)'
  silent! execute 'vmap' _ 'p  <Plug>(adviced-p)'
endfunction

if !exists('g:stackreg_no_default_key_mappings')
  StackregDefaultKeyMappings
endif


command! -bar -nargs=0 StackregDump  call stackreg#dump()




let g:loaded_stackreg = 1

" __END__
" vim: foldmethod=marker
