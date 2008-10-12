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
" Variables  "{{{1

let s:stack = []  " [[text, type], ...]








" Functions  "{{{1
function! stackreg#dump()  "{{{2
  echo string(s:stack)
endfunction




function! stackreg#pop()  "{{{2
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




function! stackreg#push()  "{{{2
  let g:stackreg_push = v:register
  if v:register == '"'
    call add(s:stack, [getreg(), getregtype()])
  endif
  return ''
endfunction




function! stackreg#top()  "{{{2
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








" __END__  "{{{1
" vim: foldmethod=marker
