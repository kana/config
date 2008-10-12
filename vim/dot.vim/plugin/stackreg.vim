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




call advice#define('dd', 'n', 'dd', 0, '')
call advice#define('yy', 'n', 'yy', 0, '')
call advice#define('Y', 'n', 'Y', 0, '')
call advice#define('p', 'n', 'p', 0, '')
call advice#define('P', 'n', 'P', 0, '')

call advice#add('dd', 'n', 'after', 'stackreg', 'Stackreg_push')
call advice#add('yy', 'n', 'after', 'stackreg', 'Stackreg_push')
call advice#add('Y', 'n', 'after', 'stackreg', 'Stackreg_push')
call advice#add('p', 'n', 'before', 'stackreg', 'Stackreg_pop')
call advice#add('P', 'n', 'before', 'stackreg', 'Stackreg_pop')

nmap dd  <Plug>(adviced-dd)
nmap yy  <Plug>(adviced-yy)
nmap Y  <Plug>(adviced-Y)
nmap p  <Plug>(adviced-p)
nmap P  <Plug>(adviced-P)

let s:stack = []  " [[text, type], ...]
command! -bar -nargs=0 StackregDump  echo s:stack

function! Stackreg_push()
  let g:stackreg_push = v:register
  if v:register == '"'
    call add(s:stack, [getreg(), getregtype()])
  endif
  return ''
endfunction

function! Stackreg_pop()
  let g:stackreg_pop = v:register
  if v:register == '"'
    if !empty(s:stack)
      let _ = remove(s:stack, -1)
    else
      let _ = ['', 'c']
    endif
    call setreg('"', _[0], _[1])
  endif
  return ''
endfunction

function! Stackreg_top()
  let g:stackreg_top = v:register
  if v:register == '"'
    if !empty(s:stack)
      let _ = s:stack[-1]
    else
      let _ = ['', 'c']
    endif
    call setreg('"', _[0], _[1])
  endif
  return ''
endfunction





let g:loaded_stackreg = 1

" __END__
" vim: foldmethod=marker
